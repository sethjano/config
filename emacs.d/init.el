;;	Jeff Mickey's .emacs.d/init.el file
;;
;;	the awkward part is that I wrote this in vim :/

;; time our .emacs loading
(defvar *emacs-load-start* (current-time))

;; Get rid of things.
(menu-bar-mode nil)
(tool-bar-mode nil)
(scroll-bar-mode nil)

;; add my site-lisp dir as a place to load things
(add-to-list 'load-path "~/.emacs.d/site-lisp")

(defun dirs-inside-directory (parent)
  (let (foo)
    (dolist (file (directory-files parent t))
      (when (and (not (member (file-name-nondirectory file)
                              '("." "..")))
                 (file-directory-p file))
        (setq foo (cons file foo))))
    foo))

;; Automagically load all folders in site-lisp as well! Thank you benny!
(mapc (lambda (x) (add-to-list 'load-path x))
		(dirs-inside-directory "~/.emacs.d/site-lisp/"))


;; fonts yay
;(add-to-list 'default-frame-alist '(font . "-xos4-terminus-medium-r-normal--12-120-72-72-c-60-iso8859-1"))
;(add-to-list 'default-frame-alist '(font . "-xos4-terminus-medium-r-normal--14-140-72-72-c-80-iso8859-1"))
;(add-to-list 'default-frame-alist '(font . "smoothansi"))
;(add-to-list 'default-frame-alist '(font . "DejaVu Sans Mono-9"))
(add-to-list 'default-frame-alist '(font . "-windows-dina-medium-r-normal--13-80-96-96-c-70-iso8859-1"))
;(add-to-list 'default-frame-alist '(font . "Consolas-13"))

;;	Get rid of the annoying bell
(setq visible-bell 1)

;; Uhh, go CL?
(require 'cl)
;;; This was installed by package-install.el.
;;; This provides support for the package system and
;;; interfacing with ELPA, the package archive.
;;; Move this code earlier if you want to reference
;;; packages in your .emacs.
(when
    (load
     (expand-file-name "~/.emacs.d/elpa/package.el"))
  (package-initialize))

;; Turn on the clock!
(autoload 'display-time "time" "clock in status bar" t) ;shut up compiler
(if (locate-library "time")
    (progn
      (require 'time)
      (defconst display-time-day-and-date t)
      (defconst display-time-24hr-format t)
      (display-time))
    (message "Get time.el from your distro."))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; auto modes
;;;
(add-to-list 'auto-mode-alist '("\\.mdwn$" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.hs$" . haskell-mode))
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(add-to-list 'auto-mode-alist '("\\.rb$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.yaml$" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.haml$" . haml-mode))
(add-to-list 'auto-mode-alist '("\\.sass$" . sass-mode))
(add-to-list 'interpreter-mode-alist '("ruby" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.gp$" . gnuplot-mode))
;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; backup files

;; Put autosave files (ie #foo#) in one place, *not*
;; scattered all over the file system!
(defvar autosave-dir
 (concat "/tmp/emacs_autosaves/" (user-login-name) "/"))

(make-directory autosave-dir t)

(defun auto-save-file-name-p (filename)
  (string-match "^#.*#$" (file-name-nondirectory filename)))

(defun make-auto-save-file-name ()
  (concat autosave-dir
   (if buffer-file-name
      (concat "#" (file-name-nondirectory buffer-file-name) "#")
    (expand-file-name
     (concat "#%" (buffer-name) "#")))))

;; Put backup files (ie foo~) in one place too. (The backup-directory-alist
;; list contains regexp=>directory mappings; filenames matching a regexp are
;; backed up in the corresponding directory. Emacs will mkdir it if necessary.)
(defvar backup-dir (concat "/tmp/emacs_backups/" (user-login-name) "/"))
(setq backup-directory-alist (list (cons "." backup-dir)))
;; http://snarfed.org/space/gnu%20emacs%20backup%20files

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; backwards kill word
;;
(global-set-key "\C-w" 'backward-kill-word)
(global-set-key "\C-x\C-k" 'kill-region)
;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; private settings
;; Here I list my "private" varables so you know what
;; things are.

;; irc
(defvar cm-freenode-pass "nope"
  "The nickserv password for freenode.")
(defvar cm-oftc-pass "nope"
  "The nickserv password for oftc.")
(defvar cm-what-pass "nope"
  "The nickserv password for what.")
(defvar cm-rizon-pass "nope"
  "The nickserv password for rizon.")
(defvar cm-bitlbee-pass "nope"
  "The password for bitlbee!")
(defvar cm-irc-channel-alist
  '(("freenode" "#archlinux" "#emacs")
    ("oftc" "#ikiwiki"))
  "The channel list..")

(load-file "~/.emacs-priv.el")
;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; server
;;;
(unless (string-equal "root" (getenv "USER"))
;; Only start server mode if it isn't started already
  (when (or (not (boundp 'server-process))
  (not (eq (process-status server-process)
  'listen)))
  (server-start)))
;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; markdown
;;
(autoload 'markdown-mode "markdown-mode.el"
   "Major mode for editing Markdown files" t)
(add-hook 'markdown-mode-hook '(lambda ()
								 (flyspell-mode 1)
								 (auto-fill-mode 1)
								 ))
;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; wiki modes
(autoload 'wikipedia-mode "wikipedia-mode.el"
  "Major mode for editing documents in Wikipedia markup." t)


(add-to-list 'auto-mode-alist '("\\.wikipedia\\.org.*\\.txt\\'" . wikipedia-mode))
(add-to-list 'auto-mode-alist '("wikid\\.netapp\\.com.*\\.txt\\'" . wikipedia-mode))
;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; elscreen
;; Elscreen - http://www.emacswiki.org/cgi-bin/wiki/EmacsLispScreen
;(require 'elscreen)
(autoload 'elscreen-one-screen-p "elscreen" "" t) 
(autoload 'elscreen-toggle "elscreen" "" t) 
(autoload 'elscreen-create "elscreen" "" t) 
(global-set-key (kbd "<C-tab>") 'elscreen-toggle)
(global-set-key [(control shift right)] 'elscreen-next)
(global-set-key [(control shift left)] 'elscreen-previous)
(global-set-key [(control t)] 'elscreen-create)

;;; C-x C-c closes frame or tab
(global-set-key "\C-x\C-c" 'intelligent-kill)

(defun intelligent-kill ()
  "quit the same way no matter what kind of window you are on"
  (interactive)
;  (kill-buffer (buffer-name))
  (if (and (not (elscreen-one-screen-p)) (elscreen-kill))
      (message "Killed screen")
    (if (eq (car (visible-frame-list)) (selected-frame))
        ;;for parent/master frame…
        (if (> (length (visible-frame-list)) 1)
            ;;a parent with children present
            (delete-frame (selected-frame))
          ;;a parent with no children present
          (save-buffers-kill-emacs))
      ;;a child frame
      (delete-frame (selected-frame)))))
;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; printing!
;; This requires xpp
;(require 'lpr)
(setq lpr-command "xpp")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; lines!
;;
(line-number-mode 1)
(column-number-mode 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ido
;; Fast buffer switching ftw!
(require 'ido)
(ido-mode t)
(setq ido-enable-flex-matching t)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; setnu
;(require 'setnu)
;(require 'setnu+)
(autoload 'setnu-mode "setnu" "" t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ecb
;; Emacs Code Browser
(load-file "/usr/share/emacs/site-lisp/cedet/common/cedet.el")
(add-to-list 'load-path "/usr/share/emacs/site-lisp/ecb")
(require 'ecb-autoloads)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; haskell
;;
(autoload 'haskell-mode "haskell-mode.el" "" t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; egg
;;
(require 'egg)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; anything
;(require 'anything)
(autoload 'anything "anything" "" t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; bbdb
;(require 'bbdb)
;(bbdb-initialize 'gnus 'message 'sc 'w3)
;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; compile me
;; Install mode-compile to give friendlier compiling support!
(autoload 'mode-compile "mode-compile"
   "Command to compile current buffer file based on the major mode" t)
(global-set-key "\C-cc" 'mode-compile)
(autoload 'mode-compile-kill "mode-compile"
 "Command to kill a compilation launched by `mode-compile'" t)
(global-set-key "\C-ck" 'mode-compile-kill)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; gnuplot
;;
(autoload 'gnuplot-mode "gnuplot" "gnuplot major mode" t)
(autoload 'gnuplot-make-buffer "gnuplot" "open a buffer in gnuplot mode" t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; git
(require 'vc-git)
(when (featurep 'vc-git) (add-to-list 'vc-handled-backends 'git))
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; muse
;;
(require 'muse-autoloads)
(add-hook 'muse-mode-hook '(lambda ()
								 (footnote-mode 1)
								 (flyspell-mode 1)
								 (auto-fill-mode 1)
								 ))
;; My wiki's!
(setq muse-project-alist
	'(("Personal Miki" ("~/miki/src" :default "index")
		(:base "html" :path "~/miki/html"))))
;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; yasnippet
;;
(require 'yasnippet-bundle)
;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ruby-mode
;;
(autoload 'ruby-mode "ruby-mode"
    "Mode for editing ruby source files")
(autoload 'run-ruby "inf-ruby"
    "Run an inferior Ruby process")
(autoload 'inf-ruby-keys "inf-ruby"
    "Set local key defs for inf-ruby in ruby-mode")
(add-hook 'ruby-mode-hook
     '(lambda ()
         (inf-ruby-keys)))
 ;; If you have Emacs 19.2x or older, use rubydb2x                              
(autoload 'rubydb "rubydb3x" "Ruby debugger" t)
 ;; uncomment the next line if you want syntax highlighting                     
(add-hook 'ruby-mode-hook 'turn-on-font-lock)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; yaml-mode
;;
(autoload 'yaml-mode "yaml-mode" "Yaml editing mode" t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; haml and such
;;
(autoload 'haml-mode "haml-mode" "" t)
(add-hook 'haml-mode-hook '(lambda ()
							(setq indent-tabs-mode nil)
							))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; EMMS
;;
(require 'emms-setup)
(emms-devel)
(setq emms-player-list
      '(emms-player-mpg321
	emms-player-ogg123))
(setq emms-info-asynchronosly t)
(add-hook 'emms-player-started-hook 'emms-show)
(setq emms-show-format "NP: %s")
(setq emms-player-mpg321-parameters '("-o" "alsa"))
(setq emms-source-list '((emms-directory-tree "~/muse/")))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; journal/diary entry
(defun insert-date ()
  (interactive)
  (insert (format-time-string "%c")))

(defun insert-header-newday ()
  (interactive)
  (insert "\n////////////////////////////////////////////////////////////////////////\n")
  (insert "// ")
  (insert-date)
  (insert "\n\n")
)

(defun insert-header-continue ()
  (interactive)
  (insert (format-time-string "\n                             ** %T **"))
  (insert "\n\n")
)

(defun insert-correct-header ()
  (interactive)
  (insert-header-newday)
)

(defun journal ()
  (interactive)
  (find-file "~/doc/journal.txt")
  (end-of-buffer)
  (insert-correct-header)
  (auto-fill-mode 1)
  (flyspell-mode 1)
)

;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; bloggin
;; This should create a new file with the next numerical value
;; and add some boilerplate

(defun blog-insert-meta ()
  (interactive)
  (insert "[[!meta title=\"\"]]\n")
  (insert "[[!tag ]]\n")
  (insert "\n")
)

(defun blog-last ()
  (interactive)
  (let ((wiki-dir "~/www/wiki/blog/"))
    (find-file
     (concat wiki-dir
	     (number-to-string (apply 'max (mapcar 'string-to-number
	     (mapcar '(lambda (a) (substring a 0 -5))
		     (directory-files wiki-dir nil "[0-9]*\\.mdwn" t )))))
	     ".mdwn")))
)

(defun blog-find-next ()
  (interactive)
  (let ((wiki-dir "~/www/wiki/blog/"))
    (find-file 
     (concat wiki-dir 
	     (number-to-string (1+ (apply 'max (mapcar 'string-to-number 
	     (mapcar '(lambda (a) (substring a 0 -5)) 
					 (directory-files wiki-dir nil "[0-9]*\\.mdwn" t))))))
	     ".mdwn")))
)

(defun blog-next ()
  (interactive)
  (blog-find-next)
  (end-of-buffer)
  (blog-insert-meta)
)

;;


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

(defun org-receipt-agenda (match)
  (setq org-agenda-include-all-todo nil
		org-agenda-ndays 7
		org-agenda-show-all-dates t
		)
  (org-agenda-list)
  )

(setq org-agenda-custom-commands
	  '(("a" "Defined Agenda"
		 ((org-agenda-list nil nil 1)
		  (sacha/org-agenda-load)
		  (sacha/org-agenda-clock)
		  (tags "PROJECT-WAITING")
		  (tags-todo "WAITING")
		  (tags-todo "-MAYBE")))
		("Z" "Receipt Agenda"
		 ((org-receipt-agenda)
		  )
		 )
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

;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; w3m
;;(require 'w3m-load)
;(require 'mime-w3m)
;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; rcirc
;(require 'rcirc)
(autoload 'irc "rcirc" "" t)
;; colors!
(eval-after-load 'rcirc '(require 'rcirc-color))

(add-hook 'rcirc-markup-colors 'rcirc-markup-text-functions)

(defvar rcirc-color-vector ["black" "red" "green" "yellow" "blue" "magenta" "cyan" "white"]
  "Vector of color names for the numbers 0-7.")

(defun rcirc-markup-colors (process sender response channel-buffer)
  (while (re-search-forward "\C-c\\([0-7]\\)\\(.*?\\)\C-c" nil t)
    (rcirc-add-face (match-beginning 0) (match-end 0)
		    (cons 'foreground-color
			  (aref rcirc-color-vector (string-to-number (match-string 1)))))
    ;; start deleting at the end
    (delete-region (1- (match-end 0)) (match-end 0))
    (delete-region (match-beginning 0) (match-end 1))))

;; turn on spell checking
(add-hook 'rcirc-mode-hook (lambda ()
			     (flyspell-mode 1)))
;; Turn on logging everything to a special buffer, for debugging.
(setq rcirc-debug-flag t)
;; scroll as little as possible
(add-hook 'rcirc-mode-hook
 (lambda ()
  (set
   (make-local-variable 'scroll-conservatively)
   8192)))

;; Change user info
(setq rcirc-default-nick "codemac")
(setq rcirc-default-user-name "codemac")
(setq rcirc-default-user-full-name "codemac")

(setq rcirc-authinfo '(("freenode" nickserv "codemac" cm-freenode-pass)))
(setq rcirc-startup-channels-alist '(("\\.freenode\\.net$" "#emacs")))

;; set up passwords and such!

;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; erc
;;
(autoload 'erc "erc" "" t)
;; some stuff stolen from pmade
;; <http://pmade.com/svn/oss/rc/trunk/emacs/emacs.d/pmade/erc.el>
;; Basic IRC Settings
(setq erc-user-full-name "codemac")
(setq erc-email-userid "j@codemac.net")
(setq erc-nick "codemac")

;; ERC Time stamps
(setq erc-timestamp-only-if-changed-flag nil)
(setq erc-timestamp-format "[%H:%M:%S] ")
(setq erc-insert-timestamp-function 'erc-insert-timestamp-left)

;; Auto-fill (static size so log files look decent)
(setq erc-fill-column 78)
(setq erc-fill-function 'erc-fill-static)
(setq erc-fill-static-center 15)

;; Ignore messages from the server that are not channel activity
;(setq erc-track-exclude-types '("JOIN" "NICK" "PART" "QUIT" "MODE"
;                                "324" "329" "332" "333" "353" "477"))
;(setq erc-track-exclude '("&bitlbee" "#emacs" "#ruby" "#applescript"))

;; Auto join the given channels
(setq erc-autojoin-channels-alist cm-irc-channel-alist)

;; Some other settings
(setq erc-prompt 'my-erc-prompt)
(setq erc-max-buffer-size 20000)
(setq erc-track-showcount t)
(setq erc-auto-query 'bury)             ; Private messages go to a hidden buffer
(setq erc-query-display 'buffer)        ; Reuse current buffer when sending private messages
(setq erc-keywords '("codemac" "jeff"))

;; Setup ERC buffers
(defun my-erc-hook ()
  "Correctly configure ERC buffers"
  (auto-fill-mode 0)                    ; disable auto fill
  (setq truncate-lines nil))            ; wrap lines

(defun my-erc-after-connect (server nick)
  (cond
   ((string-match "localhost" server) (erc-message "PRIVMSG" (concat "&bitlbee identify " cm-bitlbee-pass)))
   ((string-match "freenode"  server) (erc-message "PRIVMSG" (concat "NickServ identify " cm-freenode-pass)))
   ((string-match "oftc"      server) (erc-message "PRIVMSG" (concat "nickserv identify " cm-oftc-pass)))
   ((string-match "what"      server) (erc-message "PRIVMSG" (concat "Drone enter #what.cd codemac " cm-what-pass)))
))


;; Better Prompt
(defun my-erc-prompt ()
  (if (and (boundp 'erc-default-recipients) (erc-default-target))
      (erc-propertize (concat "[ " (erc-default-target) " ]") 'read-only t 'rear-nonsticky t 'front-nonsticky t)
    (erc-propertize (concat "[ ERC ]") 'read-only t 'rear-nonsticky t 'front-nonsticky t)))

;; Load in some ERC extra modules (you must download these separately)
(require 'erc-highlight-nicknames)
(require 'erc-nicklist)
(setq erc-nicklist-use-icons nil)
(setq erc-nicklist-voiced-position 'top)

;; Add some modules
(add-to-list 'erc-modules 'spelling)
(add-to-list 'erc-modules 'scrolltobottom)
(add-to-list 'erc-modules 'truncate)
;(add-to-list 'erc-modules 'log)
(add-to-list 'erc-modules 'highlight-nicknames)
(erc-update-modules)

;; Hook in
(add-hook 'erc-mode-hook 'my-erc-hook)
(add-hook 'erc-after-connect 'my-erc-after-connect)

;; Start a local bitlbee server
(require 'bitlbee)
(setq bitlbee-user-directory "~/.bitlbee")
(setq bitlbee-executable "/usr/sbin/bitlbee")
(bitlbee-start)

;; Give bitlbee a chance to bind to the local port
(sleep-for 1)

;; Define my ultracool erc-startup
(defun erc-startup ()
  (erc-ssl :server "irc.freenode.net" :port "6697")
  (erc :server "localhost" :port "6667")
  (erc-ssl :server "irc.oftc.net" :port "6697")
)
;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; gnus lock file
(defvar gnus-lock-filename)
(setq gnus-lock-filename "~/.machine-lock-gnus-my")
(put 'gnus 'disabled t)

(defun gf-touch (file)
  "Touches file"
  (save-excursion
(unless (file-exists-p file)
  (find-file file)
  (write-file file)
  (kill-buffer (current-buffer)))))

(defun gnusu (&rest args)
  (interactive "P")
  (if (file-exists-p gnus-lock-filename)
  (error "Can't start gnus, Lock file exists %S" gnus-lock-filename)
(call-interactively 'gnus)))
;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; wanderlust
(autoload 'wl "wl" "Wanderlust" t)
(autoload 'wl-other-frame "wl" "Wanderlust on new frame." t)
(autoload 'wl-draft "wl-draft" "Write draft with Wanderlust." t)

;; IMAP
(setq elmo-imap4-default-server "imap.gmail.com")
(setq elmo-imap4-default-user "codemac@gmail.com") 
(setq elmo-imap4-default-authenticate-type 'clear) 
(setq elmo-imap4-default-port '993)
(setq elmo-imap4-default-stream-type 'ssl)

(setq elmo-imap4-use-modified-utf7 t) 

;; SMTP
(setq wl-smtp-connection-type 'starttls)
(setq wl-smtp-posting-port 587)
(setq wl-smtp-authenticate-type "plain")
(setq wl-smtp-posting-user "mattofransen")
(setq wl-smtp-posting-server "smtp.gmail.com")
(setq wl-local-domain "gmail.com")

(setq wl-default-folder "%inbox")
(setq wl-default-spec "%")
(setq wl-draft-folder "%[Gmail]/Drafts") ; Gmail IMAP
(setq wl-trash-folder "%[Gmail]/Trash")

(setq wl-folder-check-async t) 

(setq elmo-imap4-use-modified-utf7 t)

(autoload 'wl-user-agent-compose "wl-draft" nil t)
(if (boundp 'mail-user-agent)
    (setq mail-user-agent 'wl-user-agent))
(if (fboundp 'define-mail-user-agent)
    (define-mail-user-agent
      'wl-user-agent
      'wl-user-agent-compose
      'wl-draft-send
      'wl-draft-kill
      'mail-send-hook))
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; jabber
(require 'jabber)
;(autoload 'jabber-connect-all "jabber" "" t)
;; Show my status in the header along with theirs! woo!

(setq jabber-chat-header-line-format
          '(" " (:eval (jabber-jid-displayname jabber-chatting-with))
    	" " (:eval (jabber-jid-resource jabber-chatting-with)) "\t";
    	(:eval (let ((buddy (jabber-jid-symbol jabber-chatting-with)))
    		 (propertize
    		  (or
    		   (cdr (assoc (get buddy 'show) jabber-presence-strings))
    		   (get buddy 'show))
    		  'face
    		  (or (cdr (assoc (get buddy 'show) jabber-presence-faces))
    		      'jabber-roster-user-online))))
    	"\t" (:eval (get (jabber-jid-symbol jabber-chatting-with) 'status))
    	(:eval (unless (equal "" *jabber-current-show*)
    		 (concat "\t You're " *jabber-current-show*
    			 " (" *jabber-current-status* ")")))))
;; Open urls!
(add-hook 'jabber-chat-mode-hook 'goto-address)

;; fun keybindings!
(defun my-jabber-chat-delete-or-bury ()
  (interactive)
  (if (eq 'jabber-chat-mode major-mode)
      (condition-case e 
          (delete-frame)
        (error 
         (if (string= "Attempt to delete the sole visible or iconified frame" 
                      (cadr e))
            (bury-buffer))))))

(define-key jabber-chat-mode-map [escape] 
  'my-jabber-chat-delete-or-bury)
(define-key mode-specific-map "jr"
  (lambda () 
    (interactive) 
    (switch-to-buffer "*-jabber-*")))
(define-key mode-specific-map "jc"
  '(lambda () 
     (interactive) 
     (call-interactively 'jabber-connect)))
(define-key mode-specific-map "jd"
  '(lambda () 
     (interactive) 
     (call-interactively 'jabber-disconnect)))
(define-key mode-specific-map "jj"
  '(lambda () 
     (interactive) 
     (call-interactively 'jabber-chat-with)))
(define-key mode-specific-map "ja"
  '(lambda () 
     (interactive) 
     (jabber-send-presence "away" "" 10)))
(define-key mode-specific-map "jo"
  '(lambda () 
     (interactive) 
     (jabber-send-presence "" "" 10)))
(define-key mode-specific-map "jx"
  '(lambda () 
     (interactive) 
     (jabber-send-presence "xa" "" 10)))


;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CUSTOM!
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 )

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(auto-image-file-mode t)
 '(browse-url-firefox-new-window-is-tab t)
 '(browse-url-firefox-program "firefox")
 '(ecb-options-version "2.32")
 '(jabber-account-list (quote (("j@xmpp.us") ("codemac@gmail.com" (:network-server . "talk.google.com") (:port . 5222)))))
 '(jabber-roster-line-format " %c %-25n %u %-8s  %S"))

;; COLORS PLZ
(require 'color-theme)
(load-library "color-theme-colorful-obsolescence")
(load-library "manoj-colors")
(load-library "zenburn")
(defun set-up-colors()
  (interactive)
  (setq color-theme-is-global t)
  (setq color-theme-load-all-themes nil)
  (color-theme-initialize)
;  (color-theme-colorful-obsolescence)
	(color-theme-zenburn)
  )
(set-up-colors)

;;;;;;;;;;;;;;;;;;;;;;;;; sj coding standards
(add-hook 'c-mode-hook
	  '(lambda ()
	     (setq tab-width 4)
	     (setq indent-tabs-mode 1)
	     (setq tab-stop-list 
		   '(4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80))
	     (setq fill-column 80)
	     (setq c-basic-offset 8)
	     (setq c-tab-always-indent t)
	     (setq comment-multi-line t)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; last line?
(message "My .emacs loaded in %ds" (destructuring-bind (hi lo ms) (current-time)
                             (- (+ hi lo) (+ (first *emacs-load-start*) (second *emacs-load-start*)))))
