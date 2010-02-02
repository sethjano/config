(add-to-list 'load-path "~/.emacs.d/site-lisp/org-mode/lisp")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; org mode
(require 'org)
(require 'org-mouse)

(defun sacha/org-agenda-load (match)
  "Can be included in `org-agenda-custom-commands'."
  (let ((inhibit-read-only t)
        (time (sacha/org-calculate-free-time
               ;; today
               (calendar-gregorian-from-absolute org-starting-day)
               ;; now if today, else start of day
               (if (= org-starting-day
                      (time-to-days (current-time)))
                   (let* ((now (decode-time))
                          (cur-hour (nth 2 now))
                          (cur-min (nth 1 now)))
                     (+ (* cur-hour 60) cur-min))
                 (let ((start (car (elt org-agenda-time-grid 2))))
                   (+ (* (/ start 100) 60) (% start 100))))
                 ;; until the last time in my time grid
               (let ((last (car (last (elt org-agenda-time-grid 2)))))
                 (+ (* (/ last 100) 60) (% last 100))))))
    (goto-char (point-max))
    (insert (format
             "%.1f%% load: %d minutes scheduled, %d minutes to be scheduled, %d minutes free, %d minutes gap - %.1f total work hours planned\n"
             (/ (elt time 1) (* .01 (elt time 2)))
	     (elt time 0)
             (elt time 1)
             (elt time 2)
             (- (elt time 2) (elt time 1))
	     (/ (+ (elt time 0) (elt time 1)) 60)
	     ))))

(defun sacha/org-calculate-free-time (date start-time end-of-day)
  "Return a cons cell of the form (TASK-TIME . FREE-TIME) for DATE, given START-TIME and END-OF-DAY.
DATE is a list of the form (MONTH DAY YEAR).
START-TIME and END-OF-DAY are the number of minutes past midnight."
  (save-window-excursion
  (let ((files org-agenda-files)
        (total-unscheduled 0)
        (total-gap 0)
        file
        rtn
        rtnall
        entry
	(total-scheduled 0)
        (last-timestamp start-time)
        scheduled-entries)
    (while (setq file (car files))
      (catch 'nextfile
        (org-check-agenda-file file)
        (setq rtn (org-agenda-get-day-entries file date :scheduled :timestamp))
        (setq rtnall (append rtnall rtn)))
      (setq files (cdr files)))
    ;; For each item on the list
    (while (setq entry (car rtnall))
      (let ((time (get-text-property 1 'time entry)))
        (cond
         ((and time (string-match "\\([^-]+\\)-\\([^-]+\\)" time))
          (setq scheduled-entries
		(cons
		 (cons
		  (save-match-data (appt-convert-time (match-string 1 time)))
		  (save-match-data (appt-convert-time (match-string 2 time))))
		 scheduled-entries)))
         ((and
	   time
	   (string-match "\\([^-]+\\)\\.+" time)
	   (string-match "^[A-Z]+ \\(\\[#[A-Z]\\] \\)?\\([0-9]+\\)"
			 (get-text-property 1 'txt entry)))
          (setq scheduled-entries
                (let ((start (and (string-match "\\([^-]+\\)\\.+" time)
				  (appt-convert-time (match-string 1 time)))))
                  (cons
		   (cons start
			 (and (string-match
			       "^[A-Z]+ \\(\\[#[A-Z]\\] \\)?\\([0-9]+\\) "
			       (get-text-property 1 'txt entry))
			      (+ start
				 (string-to-number
				  (match-string
				   2
				   (get-text-property 1 'txt entry))))))
                        scheduled-entries))))
         ((and
	   (get-text-property 1 'txt entry)
	   (string-match "^[A-Z]+ \\(\\[#[A-Z]\\] \\)?\\([0-9]+\\)"
			 (get-text-property 1 'txt entry)))
          (setq total-unscheduled
		(+ (string-to-number
		    (match-string 2 (get-text-property 1 'txt entry)))
		   total-unscheduled)))))
      (setq rtnall (cdr rtnall)))
    ;; Sort the scheduled entries by time
    (setq scheduled-entries
	  (sort scheduled-entries (lambda (a b) (< (car a) (car b)))))

    (while scheduled-entries
      (let ((start (car (car scheduled-entries)))
            (end (cdr (car scheduled-entries))))
      (cond
       ;; are we in the middle of this timeslot?
       ((and (>= last-timestamp start)
             (<= last-timestamp end))
        ;; move timestamp later, no change to time
	(setq total-scheduled (+ total-scheduled (- end last-timestamp)))
        (setq last-timestamp end))
       ;; are we completely before this timeslot?
       ((< last-timestamp start)
        ;; add gap to total, skip to the end
        (setq total-gap (+ (- start last-timestamp) total-gap))
	(setq total-scheduled (+ total-scheduled (- end start)))
        (setq last-timestamp end)))
      (setq scheduled-entries (cdr scheduled-entries))))
    (if (< last-timestamp end-of-day)
        (setq total-gap (+ (- end-of-day last-timestamp) total-gap)))
    (list total-scheduled total-unscheduled total-gap))))

(defun sacha/org-clock-in-if-starting ()
  "Clock in when the task is marked STARTED."
  (when (and (string= state "STARTED")
             (not (string= last-state state)))
    (org-clock-in)))
(add-hook 'org-after-todo-state-change-hook
	  'sacha/org-clock-in-if-starting)

(defadvice org-clock-in (after sacha activate)
  "Set this task's status to 'STARTED'."
  (org-todo "STARTED"))

(defun sacha/org-clock-out-if-waiting ()
  "Clock in when the task is marked STARTED."
  (when (and (string= state "WAITING")
             (not (string= last-state state)))
    (org-clock-out)))
(add-hook 'org-after-todo-state-change-hook
	  'sacha/org-clock-out-if-waiting)

(defun sacha/org-agenda-clock (match)
  ;; Find out when today is
  (let* ((inhibit-read-only t))
    (goto-char (point-max))
    (org-dblock-write:clocktable
     `(:scope agenda
       :maxlevel 4
       :tstart ,(format-time-string "%Y-%m-%d" (calendar-time-from-absolute (1+ org-starting-day) 0))
       :tend ,(format-time-string "%Y-%m-%d" (calendar-time-from-absolute (+ org-starting-day 2) 0))))))

(defvar org-my-archive-expiry-days 7
  "The number of days after which a completed task should be auto-archived.
This can be 0 for immediate, or a floating point value.")
(setq org-done-keywords (list "DONE"))

(defun org-my-archive-done-tasks ()
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (let ((done-regexp
           (concat "\\* \\(" (regexp-opt org-done-keywords) "\\) "))
          (state-regexp
           (concat "- State \"\\(" (regexp-opt org-done-keywords)
                   "\\)\"\\s-*\\[\\([^]\n]+\\)\\]")))
      (while (re-search-forward done-regexp nil t)
        (let ((end (save-excursion
                     (outline-next-heading)
                     (point)))
              begin)
          (goto-char (line-beginning-position))
          (setq begin (point))
          (if (re-search-forward state-regexp end t)
              (let* ((time-string (match-string 2))
                     (when-closed (org-parse-time-string time-string)))
                (if (>= (time-to-number-of-days
                         (time-subtract (current-time)
                                        (apply #'encode-time when-closed)))
                        org-my-archive-expiry-days)
                    (org-archive-subtree)))
            (goto-char end)))))
    (save-buffer)))

(setq safe-local-variable-values (quote ((after-save-hook archive-done-tasks))))

(defalias 'archive-done-tasks 'org-my-archive-done-tasks)

(setq org-agenda-custom-commands
	  '(("a" "Defined Agenda"
		 ((org-agenda-list nil nil 1)
		  (sacha/org-agenda-load)
		  (sacha/org-agenda-clock)
		  (tags "PROJECT-WAITING")
		  (tags-todo "WAITING")
		  (tags-todo "-MAYBE")))
		("X" agenda ""
		 ((ps-number-of-columns 3)
		  (ps-landscape-mode t)
		  (org-agenda-prefix-format " [ ] ")
		  (org-agenda-with-colors t)
		 ("theagenda.ps")
		 ))))

(setq org-stuck-projects
	  '("-MAYBE-DONE" "TODO"))

(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(setq org-return-follows-link t)
(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c a") 'org-agenda)

;; remember keystuff
(require 'remember)
(add-hook 'remember-mode-hook 'org-remember-apply-template)
(define-key global-map [(control meta ?r)] 'remember)
(setq org-remeber-store-without-prompt t)
(setq org-remember-templates '((116 "* TODO %?\n  %u" "~/org/gtd.org")
			       (110 "* %u %?" "~/org/notes.org")))
(setq remember-annotation-functions '(org-remember-annotation))
(setq remember-handler-functions '(org-remember-handler))

(setq org-default-notes-files '("~/org/notes.org"))
(setq org-agenda-files (file-expand-wildcards "~/org/*.org"))
(setq org-log-done t)
(setq org-hide-leading-stars t)
(setq org-fontify-done-headline t)
(setq org-return-follows-link t)
(setq org-agenda-include-all-todo t)
(setq org-agenda-ndays 7)
(setq org-agenda-include-diary t)
(setq org-agenda-skip-deadline-if-done t)
(setq org-agenda-skip-scheduled-if-done t)
(setq org-start-on-weekday nil)
(setq org-agenda-show-all-dates t)
(setq org-reverse-note-order t)
(setq org-fontify-done-headline t)
(setq org-special-ctrl-k t)
(setq org-special-ctrl-a/e t)

(require 'remember)
(setq remember-annotation-functions '(org-remember-annotation))
(setq remember-handler-functions '(org-remember-handler))
(add-hook 'remember-mode-hook 'org-remember-apply-template)
(setq org-remember-templates
      '(("Todo" ?t "* TODO %?\n  %i\n  %a" "~/org/gtd.org" "Inbox")
	("Future Todo" ?f "* TODO %?\n  %i\n  %^T\n  %a" "~/org/gtd.org" "Inbox")
	("Music" ?m "* TODO %?\n  %U" "~/org/music.org" "To Get")
        ("Journal" ?j "* %U %?\n\n  %i\n  %a" "~/org/JOURNAL.org")
        ("Idea" ?i "* %^{Title}\n  %i\n  %a" "~/org/JOURNAL.org" "New Ideas")))

(global-set-key (kbd "C-c r") 'org-remember)

(defun gtd ()
  (interactive)
  (find-file "~/org/gtd.org")
  )

;; Set up my diary file
(setq diary-file "~/org/diary") ;; deal with the fact that it's in the org folder
;; got this from the org ml
(require 'appt)
(setq org-agenda-include-diary t)
(setq appt-time-msg-list nil)
(org-agenda-to-appt)

(defadvice  org-agenda-redo (after org-agenda-redo-add-appts)
  "Pressing `r' on the agenda will also add appointments."
  (progn 
    (setq appt-time-msg-list nil)
    (org-agenda-to-appt)))

(ad-activate 'org-agenda-redo)

(appt-activate 1)
(setq appt-display-format 'window)
(setq appt-disp-window-function 'ba/appt-display-window)

(defun ba/appt-display-window (min-to-app new-time msg)
  (let ((int-time (string-to-int min-to-app)))
    (call-process "dtextbar" nil 0 nil
                   "-n" "-p"
                  "In" (int-to-string int-time) "mins: "
                  msg (if (< int-time 5) "-b" ""))))


;;; all these are taken from http://www.mail-archive.com/emacs-orgmode@gnu.org/msg04992.html
;; Use (current-column)
(defun current-line-length ()
  "Length of a the line at point."
  (save-excursion (end-of-line) (current-column)))

;; Use (org-write-agenda file)
(defun org-agenda-to-file (key file &optional max-line-width)
  "Write the `org-agenda' view associated with KEY to FILE.
MAX-LINE-WIDTH optionally specifies the maximum line width for
the text in the resulting file."
  (interactive)
  (save-window-excursion
    (org-agenda nil key)
    (switch-to-buffer "*Org Agenda*")
    (org-write-agenda file)
    (org-agenda-quit))
  (if max-line-width (put-file-content-in-procustes-bed
                      file max-line-width)))

;; Use a separate torture function for this
(defun put-file-content-in-procustes-bed (file max-line-width)
  "Find FILE and cut anything beyond LINE-WIDTH."
  (save-window-excursion
    (with-temp-buffer
      (find-file file)
      (kill-rectangle
       (point-min) 
       (progn (point-max) 
              (move-to-column max-line-width t)
              (point)))
      (erase-buffer)
      (yank-rectangle)
      (write-file file))))

;;;
