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

(use-package zenburn-theme
  :ensure t
  :init (load-theme 'zenburn t)
  :config
  (zenburn-with-color-variables
    (custom-theme-set-faces
     'zenburn
     `(mode-line
       ((,class (:foreground "black" :background "#f9b593" :box nil))
        (t :inverse-video t)))
     `(mode-line-inactive
       ((t (:foreground ,zenburn-green-1 :background ,zenburn-bg-05 :box nil))))
     `(mode-line-buffer-id ((t (:foreground "black" :weight bold))))
     `(powerline-active1
       ((t (:foreground ,zenburn-green-1 :background ,zenburn-bg-05
                        :inherit mode-line))))
     `(powerline-active2 ((t (:background ,zenburn-bg+2 :inherit mode-line)))))))

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


(use-package jedi-core
  :config
  (setq jedi:use-shortcuts t) ; M-. and M-,
  (add-hook 'python-mode-hook 'jedi:setup)
  (use-package company-jedi
    :ensure
    :config
    (add-hook 'python-mode-hook
              (lambda () (add-to-list 'company-backends
                                      'company-jedi)))))

