;;; julia-mode-autoloads.el --- automatically extracted autoloads
;;
;;; Code:
(add-to-list 'load-path (or (file-name-directory #$) (car load-path)))

;;;### (autoloads nil "julia-mode" "julia-mode.el" (22378 49290 403044
;;;;;;  296000))
;;; Generated autoloads from julia-mode.el

(add-to-list 'auto-mode-alist '("\\.jl\\'" . julia-mode))

(autoload 'julia-mode "julia-mode" "\
Major mode for editing julia code.

\(fn)" t nil)

(autoload 'inferior-julia "julia-mode" "\
Run an inferior instance of `julia' inside Emacs.

\(fn)" t nil)

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; End:
;;; julia-mode-autoloads.el ends here