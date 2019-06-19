(defvar *emacs-load-start* (float-time))

(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp"))

;;{{{ Fonts and Colours

(global-font-lock-mode t)                ; turn on syntax highlighting
(setq font-lock-maximum-decoration t)

(font-lock-add-keywords nil ; highlight XXX style code tags in source files
                        '(("\\<\\(FIXME\\|HACK\\|XXX\\|TODO\\)" 1
                           font-lock-warning-face prepend)))

;; Font selection graceful fallback: http://emacswiki.org/emacs/SetFonts
(defun font-candidate (&rest fonts)
  "Return existing font which first match."
  (require 'cl)
  (find-if (lambda (f) (find-font (font-spec :name f))) fonts))
(set-face-attribute 'default
                    nil
                    :font (font-candidate "Consolas-10"
                                          "Ubuntu Mono"
                                          "Droid Sans Mono-8"
                                          "DejaVu Sans Mono-10"))

;; Colour support in compilation mode
(ignore-errors
  (require 'ansi-color)
  (defun my-colorize-compilation-buffer ()
    (when (eq major-mode 'compilation-mode)
      (ansi-color-apply-on-region compilation-filter-start (point-max))))
  (add-hook 'compilation-filter-hook 'my-colorize-compilation-buffer))

;;}}}

(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("melpa" . "http://melpa.org/packages/")))
(package-initialize)

;; Bootstrap `use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile
  (require 'use-package))

(use-package diminish
  :ensure t)

(use-package session
  :ensure t
  :init
  (setq session-globals-max-size 150)
  (add-hook 'after-init-hook 'session-initialize))

(use-package comment-dwim-2
  :ensure t
  :bind ("M-;" . comment-dwim-2))

(use-package uniquify ;; Change buffer naming to filename<directory>
  :init
  (setq uniquify-buffer-name-style 'post-forward-angle-brackets))

(use-package midnight ;; Clean up stale buffers automatically
  )

;; I would disable abbrev if I knew how, but I don't know what's starting it so
;; just diminish it instead
(use-package abbrev
  :diminish abbrev-mode)

(use-package ace-jump-mode
  :ensure
  :bind ("C-c SPC" . ace-jump-mode))

(use-package ace-window ;; Better window switching with >2 windows
  :ensure t
  :bind ("C-x o" . ace-window)
  :config (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))

(use-package powerline
  :ensure t
  :init
  (powerline-default-theme)
  (setq powerline-display-mule-info nil)
  (setq powerline-display-hud nil)
  (setq powerline-display-buffer-size nil))

(use-package projectile
  :ensure t
  :config
  (defun my-format-projectile-modeline ()
    (propertize (format " |%s|" (projectile-project-name))
                'face '(:foreground "black" :background "#81a2be")))
  (defun my-conditional-projectile-modeline ()
    (if (condition-case nil (and projectile-require-project-root
                                 (projectile-project-root))
          (error nil))
        (my-format-projectile-modeline) ""))
  (setq projectile-mode-line '(:eval (my-conditional-projectile-modeline)))
  (projectile-global-mode))

(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status)
  :config
  (use-package magit-gitflow
    :diminish "GitF"
    :config (add-hook
	     'magit-mode-hook
	     'turn-on-magit-gitflow)))

(use-package company
  :ensure t
  :diminish company-mode
  :init (setq
	 company-dabbrev-downcase nil      ; preserve case in completions
	 company-idle-delay 0.1
	 company-minimum-prefix-length 1
	 company-tooltip-limit 20)
  :config (add-hook 'after-init-hook 'global-company-mode))

(use-package ido
  :ensure t
  :config
  (setq ido-enable-flex-matching t)
  (setq ido-everywhere t)
  (ido-mode t)
  (use-package flx-ido  ; better matching
    :ensure t
    :config (flx-ido-mode 1)
    ;; disable ido faces to see flx highlights.
    (setq ido-use-faces nil)))

(use-package helm
  :ensure
  :demand
  :diminish helm-mode
  :bind (("M-x" . helm-M-x)
         ("C-x b" . helm-mini)
         ("C-x C-f" . helm-find-files)
         ("M-s o" . helm-occur))
  :config (progn
            (require 'helm-config)
            (setq helm-ff-file-name-history-use-recentf t)
            (helm-mode 1)
            (use-package wgrep-helm :ensure)
            (use-package helm-projectile
              :ensure
              :config (helm-projectile-on))
            (use-package helm-git-grep
              :ensure
              :bind ("M-s g" . helm-git-grep-at-point)
              :config
              ;; Disable result limit
              (setq helm-git-grep-candidate-number-limit nil)
              ;; Invoke `helm-git-grep' from isearch.
              (define-key isearch-mode-map (kbd "C-c g") 'helm-git-grep-from-isearch)
              ;; Invoke `helm-git-grep' from other helm.
              (eval-after-load 'helm
                '(define-key helm-map (kbd "C-c g") 'helm-git-grep-from-helm)))))


(use-package cmake-mode
  :ensure
  :mode ("CMakeLists\\.txt\\'" "\\.cmake\\'"))

(use-package cmake-project
  :config
  (defun maybe-cmake-project-hook ()
    (if (file-exists-p "CMakeLists.txt") (cmake-project-mode)))
  (add-hook 'c-mode-hook 'maybe-cmake-project-hook)
  (add-hook 'c++-mode-hook 'maybe-cmake-project-hook))

(use-package clang-format
  :ensure
  :config
  (defun local-add-format-before-save ()
    ;; The fourth param makes this buffer-local
    (add-hook 'before-save-hook 'clang-format-buffer nil t))
   (add-hook 'c++-mode-hook 'local-add-format-before-save)
   (add-hook 'c-mode-hook 'local-add-format-before-save)
   (add-hook 'objc-mode-hook 'local-add-format-before-save))

(use-package irony
  :diminish "Iy"
  :config
  (setq w32-pipe-read-delay 0)
  (add-hook 'c++-mode-hook 'irony-mode)
  (add-hook 'c-mode-hook 'irony-mode)
  (add-hook 'objc-mode-hook 'irony-mode)
  (defun my-irony-mode-hook ()
    (define-key irony-mode-map [remap completion-at-point]
      'irony-completion-at-point-async)
    (define-key irony-mode-map [remap complete-symbol]
      'irony-completion-at-point-async))
  (add-hook 'irony-mode-hook 'my-irony-mode-hook)
  (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
  (use-package company-irony
    :config
    (use-package company-irony-c-headers
      :config
      (eval-after-load 'company
        '(add-to-list 'company-backends '(company-irony-c-headers company-irony))))
    ;; completion at interesting places, such as after scope operator
    ;; std::|
    (add-hook 'irony-mode-hook 'company-irony-setup-begin-commands))
  (use-package flycheck-irony
    :config
    (eval-after-load 'flycheck
      '(add-hook 'flycheck-mode-hook #'flycheck-irony-setup))))

(use-package flycheck
  :ensure
  :config
  (add-hook 'after-init-hook 'global-flycheck-mode)
  (flycheck-add-mode 'javascript-eslint 'web-mode)
  (flycheck-add-mode 'javascript-eslint 'js2-mode)
  ;; disable jshint since we prefer eslint checking
  (setq-default flycheck-disabled-checkers
                (append flycheck-disabled-checkers
                        '(javascript-jshint))))

(defun recompile-dwim ()
  (interactive)
  (if (condition-case nil (and projectile-require-project-root
                               (projectile-project-root))
        (error nil))
      (projectile-compile-project nil) (recompile)))

(use-package jedi-core
  :ensure
  :config
  (setq jedi:use-shortcuts t) ; M-. and M-,
  (add-hook 'python-mode-hook 'jedi:setup)
  (use-package company-jedi
    :ensure
    :config
    (add-hook 'python-mode-hook
              (lambda () (add-to-list 'company-backends
                                      'company-jedi)))))
(use-package py-autopep8
  :ensure
  :config
  (setq py-autopep8-options '("--max-line-length=99"))
  (defun python-mode-keys ()
    "Modify python-mode local key map"
    (local-set-key (kbd "C-c C-p") 'py-autopep8-buffer))
  (add-hook 'python-mode-hook 'python-mode-keys))

(add-hook 'python-mode-hook 'subword-mode)
(add-hook 'python-mode-hook
          (lambda () (local-set-key (kbd "C-c C-c") 'recompile)))
;; Please/Blaze files are Python-like
(add-to-list 'auto-mode-alist '("BUILD\\'" . python-mode))

(use-package web-mode
  :ensure
  :mode (("\\.jsx?$" . web-mode))
  :config
  (defun my-web-mode-hook ()
    ;; short circuit js mode and just do everything in jsx-mode
    (if (equal web-mode-content-type "javascript")
        (web-mode-set-content-type "jsx"))
    (setq web-mode-markup-indent-offset 2
          web-mode-css-indent-offset 2
          web-mode-code-indent-offset 2)
    (set-variable 'indent-tabs-mode nil)
    (tern-mode t))
  (add-hook 'web-mode-hook 'my-web-mode-hook)
  (add-hook 'web-mode-hook 'subword-mode))

(use-package js2-mode
  :config
  (setq-default indent-tabs-mode nil)
  (defun my-js2-mode ()
    (set-variable 'indent-tabs-mode nil)
    (setq-default js2-basic-offset 2)
    (setq mode-name "js")
    (tern-mode t))
  (add-hook 'js2-mode-hook 'my-js2-mode)
  (add-hook 'js2-mode-hook 'subword-mode)
  (use-package js2-refactor
    :config
    (add-hook 'js2-mode-hook #'js2-refactor-mode)
    (js2r-add-keybindings-with-prefix "C-c C-m")))

(use-package tern
  :config
  (use-package company-tern
    :init (eval-after-load 'company
            '(add-to-list 'company-backends 'company-tern))))

(use-package json-mode
  :config
  (add-hook 'json-mode-hook
            (lambda ()
              (make-local-variable 'js-indent-level)
              (setq js-indent-level 2))))

(use-package scss-mode
  :mode (("\\.scss$" . scss-mode))
  :config (setq scss-compile-at-save nil))

(use-package go-mode
  :commands go-mode
  :init
  (progn
    ;;(setq gofmt-command "goimports")
    ;; (add-hook 'before-save-hook 'gofmt-before-save)
    (bind-key [remap find-tag] #'godef-jump))
  :config
  (add-hook 'go-mode-hook 'electric-pair-mode)
  (add-hook 'go-mode-hook 'flycheck-mode)
  (use-package company-go
    :ensure t
    :defer t
    :init
    (with-eval-after-load 'company
      (add-to-list 'company-backends 'company-go)))
  (use-package go-eldoc
    :ensure t
    :defer
    :init
    (add-hook 'go-mode-hook 'go-eldoc-setup)))

(use-package restclient)

(use-package dockerfile-mode
  :mode (("Dockerfile\\'" . dockerfile-mode)))

(use-package docker)

(use-package which-key
  :ensure
  :diminish which-key-mode
  :config (which-key-mode t))

(use-package expand-region
  :ensure
  :bind ("C-@" . er/expand-region))

(use-package diff-hl
  :ensure
  :init
  (add-hook 'prog-mode-hook 'diff-hl-mode))

(use-package diff-hl-dired
  :init
  (add-hook 'dired-mode-hook 'diff-hl-dired-mode))

(use-package symon)

(defun my-c-mode-common-hook ()
  ;; force only spaces for indentation
  (setq indent-tabs-mode nil
        tab-width 4
        c-basic-offset tab-width)
  (local-set-key (kbd "C-c C-c") 'recompile))
(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)

(defun maybe-libssh2-style ()
  (when (and buffer-file-name
             (string-match "libssh2" buffer-file-name))
    (load "libssh2-style")
    (libssh2-c-mode-common-hook)))
(add-hook 'c-mode-hook 'maybe-libssh2-style)

(defun my-emacs-lisp-mode-hook ()
  ;; force only spaces for indentation
  (setq indent-tabs-mode nil))
(add-hook 'emacs-lisp-mode-hook 'my-emacs-lisp-mode-hook)

(defun my-python-mode-hook ()
  ;; force only spaces for indentation
  (setq indent-tabs-mode nil))
(add-hook 'python-mode-hook 'my-python-mode-hook)

(c-add-style "my-bsd"
             '("bsd"
               (c-offsets-alist
                (innamespace . -))))
(setq c-default-style
      '((java-mode . "java") (awk-mode . "awk") (other . "my-bsd")))

(use-package protobuf-mode
  :config
  (defconst my-protobuf-style
    '((c-basic-offset . 4) (indent-tabs-mode . nil)))
  (add-hook 'protobuf-mode-hook 'subword-mode)
  (add-hook 'protobuf-mode-hook
            (lambda () (c-add-style "my-style" my-protobuf-style t))))

;;{{{ Miscellaneous

(global-set-key (kbd "C-c C-c") 'recompile)
(global-set-key (kbd "M-s r") 'rgrep)


(defun visit-term-buffer ()
  "Create or visit a terminal buffer."
  (interactive)
  (if (not (get-buffer "*ansi-term*"))
      (progn
        (split-window-sensibly (selected-window))
        (other-window 1)
        (ansi-term (getenv "SHELL")))
    (switch-to-buffer-other-window "*ansi-term*")))
(global-set-key (kbd "C-x t") 'visit-term-buffer)

(setq-default fill-column 80)
(prefer-coding-system 'utf-8)
(setq inhibit-startup-message t)         ; turn off splash screen
(if (display-graphic-p)
    (progn
      (tool-bar-mode -1)                 ; turn off tool bar
      (scroll-bar-mode -1)))             ; turn off scroll bars
(show-paren-mode t)                      ; turn on paranthesis highlighting
(setq case-fold-search t)                ; make search ignore case
(setq ediff-window-setup-function 'ediff-setup-windows-plain) ; dont pop up ediff command window
(add-to-list                             ; Make log files auto-tail
 'auto-mode-alist '("\\.log\\'" . auto-revert-mode))
(add-hook                                ; strip trailing whitespace on save
 'before-save-hook 'delete-trailing-whitespace)
(setq-default indicate-empty-lines t)    ; show end-of-file in fringe
(global-set-key (kbd "C-j") 'newline)    ; Give C-J same behaviour as RET > 24.1
(setq scroll-preserve-screen-position 'always) ; Restore point when scrolling back
(setq vc-follow-symlinks t)              ; Don't prompt to follow symlinks
(setq split-height-threshold nil)        ; Prefer horizontal split

(defun my-compilation-mode-hook ()
  ;; wrapping in compilation window
  (setq truncate-lines nil)
  (setq truncate-partial-width-windows nil)

  (setq compilation-skip-threshold 2)      ; skip warning on compilation next
  (setq compilation-auto-jump-to-first-error t) ; scroll to first error

  ;; Recognise Boost.Test failures
  (add-to-list 'compilation-error-regexp-alist 'boost)
  (add-to-list 'compilation-error-regexp-alist-alist
               '(boost
                 "^\\(.*\\)(\\([0-9]+\\)): \\(?:\\(?:fatal \\)?error\\|warnin\\(g\\)\\) in \"[^\"]+\"" 1 2 nil (3)))

  ;; Recognise addtional MSVC messages - like built-in MS rule, but accepts any
  ;; word after see. Used to catch "see reference"
  (add-to-list 'compilation-error-regexp-alist 'msft-see)
  (add-to-list 'compilation-error-regexp-alist-alist
               '(msft-see "^ *\\([0-9]+>\\)? *\\(\\(?:[a-zA-Z]:\\)?[^:(	\n]+\\)(\\([0-9]+\\)) ?: \\(?:see\\|could be\\|or\\|note\\) " 2 3 nil
       0)))
(add-hook 'compilation-mode-hook 'my-compilation-mode-hook)

(cond
 ((executable-find "aspell")
  (setq ispell-program-name "aspell")
  (setq ispell-extra-args '("--sug-mode=ultra" "--lang=en_GB")))
 ((executable-find "hunspell")
  (setq ispell-program-name "hunspell")
  (setq ispell-extra-args '("-d en_GB")))
 )

;;}}}

;;{{{ Backups

(setq backup-directory-alist `(("." . "~/.backups_emacs")))
(setq backup-by-copying t)
(setq delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)

;;}}}

;;{{{ Flymake

					; Show error under cursor in minibuffer
(eval-after-load 'flymake '(require 'flymake-cursor))

					; Show error markers in fringe
(eval-after-load 'flymake '(require 'rfringe))

;;}}}


;;{{{ Windows-specific

(when (string-equal system-type "windows-nt")
  ;; Prevent issues with the Windows null device (NUL)
  ;; when using Unix find with rgrep.
  ;; (defadvice grep-compute-defaults (around grep-compute-defaults-advice-null-device)
  ;;   (let ((grep-use-null-device nil))
  ;;     ad-do-it))

  ;; (ad-activate 'grep-compute-defaults)

  ;; Use binaries from ezwinports
  (setenv "PATH"
          (concat (expand-file-name "~/.emacs.d/bin/win32/")
                  ";" (getenv "PATH")))
  )

;;}}}

;;{{{ Erc

;; Loads password using auth-source (from .authinfo)

(use-package erc
  :commands erc
  :config
  (setq erc-server "irc.freenode.net"
        erc-port 6667
        erc-nick "a_lamaison"
        erc-prompt-for-password nil
        erc-prompt-for-nickserv-password nil
        erc-hide-list '("JOIN" "PART" "QUIT" "NICK" "MODE"))

  (use-package erc-join
    :config
    (erc-autojoin-mode t)
    (setq erc-join-buffer 'bury
          erc-autojoin-channels-alist
          (list `(".*\\.freenode.net" "#emacs" "#libssh2"))))

  (use-package erc-track
    :config
    (erc-track-mode t)
    (setq erc-track-exclude-types '("JOIN" "NICK" "PART" "QUIT" "MODE"
                                    "324" "329" "332" "333" "353" "477"))))

;;}}}

(use-package visual-regexp-steroids
  :config
  (define-key global-map (kbd "C-M-%") 'vr/query-replace)
  (define-key esc-map (kbd "C-M-r") 'vr/isearch-backward) ;; C-M-r
  (define-key esc-map (kbd "C-M-s") 'vr/isearch-forward) ;; C-M-s
  (setq vr/engine 'pcre2el))

(message "My .emacs loaded in %.2fs" (- (float-time) *emacs-load-start*))


















;; (require 'package)
;; (setq package-enable-at-startup nil)
;; (setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
;;                          ("melpa" . "http://melpa.org/packages/")))
;; (package-initialize)

;; ;; Bootstrap `use-package'
;; (unless (package-installed-p 'use-package)
;;   (package-refresh-contents)
;;   (package-install 'use-package))
;; (eval-when-compile
;;   (require 'use-package))

;;;_ , solarized-theme
(use-package color-theme-sanityinc-solarized
  :ensure t
  :config (color-theme-sanityinc-solarized-dark)
  :if (display-graphic-p)
  :init
  (progn
    (setq custom-enabled-themes '(sanityinc-solarized-dark))
    (setq custom-safe-themes
      '("4cf3221feff536e2b3385209e9b9dc4c2e0818a69a1cdb4b522756bcdf4e00a4"
        "4aee8551b53a43a883cb0b7f3255d6859d766b6c5e14bcb01bed572fcbef4328"
	default))))

;; (use-package powerline
;;   :ensure t
;;   :init
;;   (powerline-default-theme)
;;   (setq powerline-display-mule-info nil)
;;   (setq powerline-display-hud nil)
;;   (setq powerline-display-buffer-size nil))

;; (use-package projectile
;;   :ensure t
;;   :config
;;   (defun my-format-projectile-modeline ()
;;     (propertize (format " |%s|" (projectile-project-name))
;;                 'face '(:foreground "black" :background "#81a2be")))
;;   (defun my-conditional-projectile-modeline ()
;;     (if (condition-case nil (and projectile-require-project-root
;;                                  (projectile-project-root))
;;           (error nil))
;;         (my-format-projectile-modeline) ""))
;;   (setq projectile-mode-line '(:eval (my-conditional-projectile-modeline)))
;;   (projectile-global-mode))

;; (use-package magit
;;   :ensure t
;;   :bind ("C-x g" . magit-status)
;;   :config
;;   (use-package magit-gitflow
;;     :diminish "GitF"
;;     :config (add-hook
;; 	     'magit-mode-hook
;; 	     'turn-on-magit-gitflow)))

;; (use-package company
;;   :ensure t
;;   :diminish company-mode
;;   :init (setq
;; 	 company-dabbrev-downcase nil      ; preserve case in completions
;; 	 company-idle-delay 0.1
;; 	 company-minimum-prefix-length 1
;; 	 company-tooltip-limit 20)
;;   :config (add-hook 'after-init-hook 'global-company-mode))


;; (use-package jedi-core
;;   :config
;;   (setq jedi:use-shortcuts t) ; M-. and M-,
;;   (add-hook 'python-mode-hook 'jedi:setup)
;;   (use-package company-jedi
;;     :ensure
;;     :config
;;     (add-hook 'python-mode-hook
;;               (lambda () (add-to-list 'company-backends
;;                                       'company-jedi)))))
;; (use-package neotree
;;   :init
;;   (progn
;;     ;; Every time when the neotree window is opened, it will try to find current
;;     ;; file and jump to node.
;;     (setq-default neo-smart-open t)
;;     ;; Do not allow neotree to be the only open window
;;     (setq-default neo-dont-be-alone t))
;;   :config
;;   (progn
;;     (setq neo-theme 'nerd))) ; 'classic, 'nerd, 'ascii, 'arrow


;; (setq inhibit-startup-message t)         ; turn off splash screen
;; (if (display-graphic-p)
;;     (progn
;;       (tool-bar-mode -1)                 ; turn off tool bar
;;       (scroll-bar-mode -1)))             ; turn off scroll bars
;; (show-paren-mode t)                      ; turn on paranthesis highlighting
;; (setq case-fold-search t)                ; make search ignore case
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (sanityinc-solarized-dark)))
 '(package-selected-packages
   (quote
    (yaml-mode zenburn-theme which-key wgrep-helm web-mode use-package session py-autopep8 powerline magit helm-projectile helm-git-grep flycheck flx-ido expand-region diff-hl company comment-dwim-2 color-theme-sanityinc-solarized cmake-mode clang-format ace-window ace-jump-mode)))
 '(session-use-package t nil (session)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
