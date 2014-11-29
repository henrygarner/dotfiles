;;;; Initialize ;;;;

(require 'cask "/usr/local/share/emacs/site-lisp/cask.el")
(cask-initialize)

(add-to-list 'load-path "~/.emacs.d/lisp")
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")

(defun maybe-install-and-require (p)
  (when (not (package-installed-p p))
    (package-install p))
  (require p))

(maybe-install-and-require 'use-package)

;; Add /usr/local/bin to path
(setenv "PATH" (concat (getenv "PATH") ":/usr/local/bin"))
(setq exec-path (append exec-path '("/usr/local/bin")))

(setq default-directory (getenv "HOME"))

(use-package better-defaults)

;;;; Editor ;;;;

(let ((font "Menlo:pixelsize=12"))
  (set-face-attribute 'default nil :font font)
  (set-frame-font font nil t))

(setq inhibit-startup-message t)
(blink-cursor-mode 0)
(menu-bar-mode -1)

;; Disable annoying visible bell on OSX
(setq visible-bell nil)

;; Actually, why not disable the annoying audible bell as well
(setq ring-bell-function 'ignore)

;; Mac Emacs settings
(setq mac-option-modifier 'meta)
(setq mac-command-modifier 'super)

;; Buffer settings
(setq default-indicate-empty-lines t)
(setq require-final-newline t)
(setq show-trailing-whitespace t)

;; Color theme
(load-theme 'henry t)

;; Custom mode-line
(use-package powerline
  :init
  (use-package diminish
    :config
    (progn
      (eval-after-load "undo-tree" '(diminish 'undo-tree-mode))
      (eval-after-load "simple" '(diminish 'auto-fill-function))
      (eval-after-load "eldoc" '(diminish 'eldoc-mode))
      (eval-after-load "elisp-slime-nav" '(diminish 'elisp-slime-nav-mode "sln"))
      (eval-after-load "projectile" '(diminish 'projectile-mode " prj"))
      (eval-after-load "paredit" '(diminish 'paredit-mode " par"))
      (eval-after-load "company" '(diminish 'company-mode " cmp"))
      (eval-after-load "cider" '(diminish 'cider-mode " cid")))))

;; No slow stupid flyspell. Die!
(eval-after-load "flyspell"
  '(defun flyspell-mode (&optional arg)))

;;;; Modes ;;;;

(add-hook 'emacs-lisp-mode-hook 'prettify-symbols-mode)
(add-hook 'clojure-mode-hook 'prettify-symbols-mode)

(use-package paredit
  :init
  (progn
    (add-hook 'emacs-lisp-mode-hook 'paredit-mode)
    (add-hook 'clojure-mode-hook 'paredit-mode)))

(use-package parenface)

(use-package company
  :init (global-company-mode)
  :config
  (progn
    (defun indent-or-complete ()
      (interactive)
      (if (looking-at "\\_>")
          (company-complete-common)
        (indent-according-to-mode)))

    (global-set-key "\t" 'indent-or-complete)))

(use-package ido
  :config
  (progn
    (global-set-key (kbd "s-b") 'ido-switch-buffer)
    (global-set-key (kbd "s-o") 'ido-find-file)))

(use-package flx-ido
  :init (flx-ido-mode 1)
  :config (setq ido-use-faces nil))

(use-package ido-vertical-mode
  :init (ido-vertical-mode 1))

(use-package projectile
  :init (projectile-global-mode)
  :config
  (progn
    (global-set-key (kbd "s-p") 'projectile-find-file)))

(use-package yasnippet
  :init
  (progn
    (yas-global-mode 1)
    (use-package clojure-snippets)))

(use-package yaml-mode
  :mode ("\\.yml$" . yaml-mode))

(use-package markdown-mode
  :mode (("\\.markdown$" . markdown-mode)
         ("\\.md$" . markdown-mode)))
(use-package glsl-mode)

(use-package clojure-mode
  :mode ("\\.edn$" . clojure-mode)
  :init
  (progn
    (use-package cider
      :init
      (progn
        (add-hook 'cider-mode-hook 'cider-turn-on-eldoc-mode)
        (add-hook 'cider-repl-mode-hook 'subword-mode)
        (use-package slamhound))
      :config
      (progn
        (setq nrepl-hide-special-buffers t)
        (setq cider-popup-stacktraces-in-repl t)
        (setq cider-repl-history-file "~/.emacs.d/nrepl-history")
        (setq cider-repl-pop-to-buffer-on-connect nil)
        (setq cider-repl-use-clojure-font-lock t)
        (setq cider-auto-select-error-buffer nil)
        (setq cider-prompt-save-file-on-load nil))))
  :config
  (progn
    (define-clojure-indent
      (defroutes 'defun)
      (GET 2)
      (POST 2)
      (PUT 2)
      (DELETE 2)
      (HEAD 2)
      (ANY 2)
      (context 2))

    (define-clojure-indent
      (form-to 1))

    (define-clojure-indent
      (match 1)
      (are 2))

    (define-clojure-indent
      (select 1)
      (insert 1)
      (update 1)
      (delete 1))

    (define-clojure-indent
      (run* 1)
      (fresh 1))

    (define-clojure-indent
      (extend-freeze 2)
      (extend-thaw 1))

    (define-clojure-indent
      (go-loop 1))

    (define-clojure-indent
      (assoc-some 1))

    (setq clojure--prettify-symbols-alist
          '(("fn"  . ?λ)
            ("comp" . ?∘)
            ("not=" . ?≠)
            ("<=" . ?≤)
            (">=" . ?≥)))

    (defun toggle-nrepl-buffer ()
      "Toggle the nREPL REPL on and off"
      (interactive)
      (if (string-match "cider-repl" (buffer-name (current-buffer)))
          (delete-window)
        (cider-switch-to-relevant-repl-buffer)))

    (defun cider-project-reset ()
      (interactive)
      (cider-interactive-eval "(user/reset)"))

    (global-set-key (kbd "s-r") 'toggle-nrepl-buffer)))

(use-package clj-refactor
  :init
  (add-hook 'clojure-mode-hook (lambda () (clj-refactor-mode 1))))

(use-package ox-reveal)
