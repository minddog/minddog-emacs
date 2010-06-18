(setq load-path (cons "~/.emacs.d" load-path))
(setq load-path (cons "~/.emacs.d/emacs-rails" load-path))
(require 'cl)
(require 'javascript-mode)
(require 'moz)
(require 'find-recursive)
(require 'snippet)
;;(require 'python-mode)
(require 'font-lock)
(require 'psvn)
(require 'php-mode)
(require 'csharp-mode)
;; Ruby and ROR setup
(add-to-list 'load-path (expand-file-name "~/.emacs.d/rails-minor-mode"))
(add-to-list 'load-path (expand-file-name "~/.emacs.d/rhtml-minor-mode"))
(add-to-list 'load-path (expand-file-name "~/.emacs.d/yaml-mode"))
(require 'ruby-mode)
(require 'inf-ruby)
(require 'rails)
(require 'rhtml-mode)
(require 'yaml-mode)
(add-to-list 'load-path (expand-file-name "~/.emacs.d/color-theme"))
(require 'color-theme)
(require 'color-theme)
(require 'haxe-mode)
(require 'objc-c-mode)
(require 'objj-mode)

(eval-after-load "color-theme"
  '(progn
     (color-theme-initialize)
     (color-theme-renegade)))

;;(normal-erase-is-backspace-mode 1)
(global-font-lock-mode 1)
(transient-mark-mode 1)
(delete-selection-mode 1)
(setq make-backup-files nil)
(menu-bar-mode -1)


;;backup and autosave prefs
(defvar user-temporary-file-directory
  (concat temporary-file-directory user-login-name "/"))
(make-directory user-temporary-file-directory t)
(setq backup-by-copying t)
(setq auto-save-list-file-prefix
      (concat user-temporary-file-directory ".auto-saves-"))
(setq auto-save-file-name-transforms
      `((".*" ,user-temporary-file-directory t)))


;; tab preferences
(defun make-tab-stop-list (width max)
  "Build a tab stop list for a given tab width and maximum line width"
  (labels ((aux (i) (if (<= i max) (cons i (aux (+ i width))))))
    (aux width)))

(defun set-tabs-local (width use-tabs)
  "Set local tab width and whether or not tab characters should be used"
  (setq c-basic-offset width)
  (setq sgml-basic-offset width)
  (setq javascript-indent-level width)
  (setq cssm-indent-level width)  (setq indent-tabs-mode use-tabs)  (setq tab-stop-list (make-tab-stop-list width 80))
  (setq tab-width width))

(defun make-tabs-global ()
  "Make current local tab settings the default"
  (interactive)
  (setq-default indent-tabs-mode indent-tabs-mode)
  (setq-default tab-stop-list tab-stop-list)
  (setq-default tab-width tab-width))

(defun set-tabs ()
  "Configure tab settings for this buffer"
  (interactive)
  (set-tabs-local
   (- (read-char "Tab width: ") ?0)
   (y-or-n-p "Use tab character? "))
  (if (y-or-n-p "Make settings global? ")
      (make-tabs-global))
  (message nil))

(set-tabs-local 4 1)
(make-tabs-global)

(global-set-key
 "\C-H"
 '(lambda ()
    "Insert HTPL block"
    (interactive)
    (let ((name (read-string "Name: "))
          (start (min (region-beginning) (region-end)))
          (end (max (region-beginning) (region-end))))
      (save-excursion
        (goto-char end)
        (back-to-indentation)
        (insert "<!--- END: " name " --->")
        (newline-and-indent)
        (previous-line)
        (indent-according-to-mode)
        (goto-char start)
        (back-to-indentation)
        (insert "<!--- BEGIN: " name " --->")
        (newline-and-indent)))))


(defun mark-line (arg)
  (interactive "p")
  (beginning-of-line nil)
  (set-mark-command nil)
  (forward-line arg))

(global-set-key "\C-V" 'mark-line)
 
(global-set-key "\C-D" 'svn-status-show-svn-diff-for-marked-files)
(global-set-key [S-f5] 'svn-status)


(add-hook 'c-mode-common-hook
          (lambda ()
            (c-set-style "java")
            (c-set-offset 'case-label '+)
            (c-set-offset 'substatement-open 0)
            (setq c-basic-offset tab-width)
            (define-key c-mode-map "\C-m" 'newline-and-indent)
            (when (fboundp 'c-subword-mode)
              (c-subword-mode 1))))

;; (setq browse-url-browser-function 'browse-url-lynx-emacs)

(defun comment-line ()
  (interactive)
  (if (= (line-beginning-position) (line-end-position))
      (next-line 1)
    (progn
      (back-to-indentation)
      (set-mark-command nil)
      (end-of-line nil)
      (comment-dwim nil)
      (back-to-indentation)
      (next-line 1))))

(global-set-key "\M-#" 'comment-line)

(global-set-key "\M-\C-\T" 'bs-show)
(global-set-key "\M-n" 'bs-cycle-next)
(global-set-key "\M-p" 'bs-cycle-prev)


;; css-mode settings
(autoload 'css-mode "css-mode")
(setq auto-mode-alist
      (cons '("\\.css\\'" . css-mode) auto-mode-alist))
(setq auto-mode-alist
      (cons '("\\.php\\'" . php-mode) auto-mode-alist))
(setq auto-mode-alist
      (cons '("\\.hx\\'" . haxe-mode) auto-mode-alist))
(setq cssm-indent-function #'cssm-c-style-indenter)
(add-hook 'css-mode-hook
          (lambda ()
            (define-key cssm-mode-map "}" 'self-insert-command)
            (cssm-leave-mirror-mode)))


;; tramp-mode
(setq tramp-default-method "ssh")
(setq tramp-default-user "adam")

;; (add-to-list 'tramp-default-user-alist
             ;; '("ssh" "\\`apps\\.dev\\.twilio\\.com'" "apps"))

(defvar find-file-root-prefix (if (featurep 'xemacs) "/[sudo/root@localhost]" "/sudo:root@localhost:" )
  "*The filename prefix used to open a file with `find-file-root'.")

(defvar find-file-root-history nil
  "History list for files found using `find-file-root'.")

(defvar find-file-root-hook nil
  "Normal hook for functions to run after finding a \"root\" file.")

(defun find-file-root ()
  "*Open a file as the root user.
   Prepends `find-file-root-prefix' to the selected file name so that it
   maybe accessed via the corresponding tramp method."

  (interactive)
  (require 'tramp)
  (let* ( ;; We bind the variable `file-name-history' locally so we can
          ;; use a separate history list for "root" files.
          (file-name-history find-file-root-history)
           (name (or buffer-file-name default-directory))
            (tramp (and (tramp-tramp-file-p name)
                             (tramp-dissect-file-name name)))
             path dir file)

    ;; If called from a "root" file, we need to fix up the path.
    (when tramp
      (setq path (tramp-file-name-path tramp)
                dir (file-name-directory path)))

    (when (setq file (read-file-name "Find file (UID = 0): " dir path))
      (find-file (concat find-file-root-prefix file))
      ;; If this all succeeded save our new history list.
      (setq find-file-root-history file-name-history)
      ;; allow some user customization
      (run-hooks 'find-file-root-hook))))

;; (defun vc-svn-registered (file) nil)
;; (defadvice vc-svn-registered (around my-vc-svn-registered-tramp activate)
  ;; "Don't try to use SVN on files accessed via TRAMP."
  ;; (if (and (fboundp 'tramp-tramp-file-p)
           ;; (tramp-tramp-file-p (ad-get-arg 0)))
      ;; nil
    ;; ad-do-it))


;; Ruby and Rails
(add-to-list 'auto-mode-alist '("\\.builder$" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.rake$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Capfile$" . ruby-mode))


;; Python settings
(add-hook 'python-mode-hook
     (lambda ()
      (define-key python-mode-map "\"" 'electric-pair)
      (define-key python-mode-map "\'" 'electric-pair)
      (define-key python-mode-map "(" 'electric-pair)
      (define-key python-mode-map "[" 'electric-pair)
      (define-key python-mode-map "{" 'electric-pair)))
(defun electric-pair ()
  "Insert character pair without surrounding spaces"
  (interactive)
  (let (parens-require-spaces)
    (insert-pair)))
;;; bind RET to py-newline-and-indent
(add-hook 'python-mode-hook '(lambda () 
     (define-key python-mode-map "\C-m" 'newline-and-indent)))

;; (defun kill-region-tabify ()
  ;; (interactive)
  ;; (if indent-tabs-mode
      ;; (tabify (region-beginning) (region-end))
    ;; (untabify (region-beginning) (region-end)))
  ;; (kill-region))

;; Cut/Copy/Paste
(global-set-key "\C-W" 'kill-region)
(global-set-key "\C-Y" 'yank)
