;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;;Key Configuration for Doom as Vanilla Emacs
(setq evil-default-state 'emacs)

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "John Doe"
      user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
;; Place your private configuration here
;; (load! "+ui")

(setq doom-scratch-buffer-major-mode 'emacs-lisp-mode)
(use-package! avy
  :commands (avy-goto-char-timer)
  :init
  (setq avy-timeout-seconds 0.2)
  ;; (setq avy-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l ?q ?w ?e ?r ?u ?i ?o ?p))
  )

(after! company
  (setq company-minimum-prefix-length 2
        company-quickhelp-delay nil
        company-show-numbers t
        company-global-modes '(not comint-mode erc-mode message-mode help-mode gud-mode)
        ))

(use-package! company-lsp
  :load-path "~/Dev/Emacs/company-lsp"
  :after lsp-mode
  :config
  (setq company-transformers nil company-lsp-cache-candidates nil)
  (set-company-backend! 'lsp-mode 'company-lsp)
  )

(after! d-mode
  (require 'lsp)
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection "dls")
    :major-modes '(d-mode)
    :priority -1
    :server-id 'ddls))
  (add-hook 'd-mode-hook #'lsp)
  )

(set-lookup-handlers! 'emacs-lisp-mode :documentation #'helpful-at-point)

(use-package! eglot)


(after! flycheck
  ;; (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (setq-default flycheck-disabled-checkers '(c/c++-clang c/c++-cppcheck c/c++-gcc))
  (global-flycheck-mode -1)
  )

(after! flymake-proc
  ;; disable flymake-proc
  (setq-default flymake-diagnostic-functions nil)
  )
(defvar flymake-posframe-delay 0.5)
(defvar flymake-posframe-buffer "*flymake-posframe*")
(defvar flymake-posframe--last-diag nil)
(defvar flymake-posframe--timer nil)

(defun flymake-posframe-hide ()
  (posframe-hide flymake-posframe-buffer))

(defun flymake-posframe-display ()
  (when flymake-mode
    (if-let (diag (and flymake-mode
                       (get-char-property (point) 'flymake-diagnostic)))
        (unless (and (eq diag flymake-posframe--last-diag)
                     (frame-visible-p (buffer-local-value 'posframe--frame (get-buffer flymake-posframe-buffer))))
          (setq flymake-posframe--last-diag diag)
          (posframe-show
           flymake-posframe-buffer
           :string (propertize (concat "➤ " (flymake--diag-text diag))
                               'face
                               (case (flymake--diag-type diag)
                                 (:error 'error)
                                 (:warning 'warning)
                                 (:note 'info)))))
      (flymake-posframe-hide))))

(defun flymake-posframe-set-timer ()
  (when flymake-posframe--timer
    (cancel-timer flymake-posframe--timer))
  (setq flymake-posframe-timer
        (run-with-idle-timer flymake-posframe-delay nil #'flymake-posframe-display)))

(use-package! frog-jump-buffer)

(use-package! lsp-mode
  :load-path "~/Dev/Emacs/lsp-mode"
  :commands lsp
  :config
  (setq lsp-auto-guess-root t lsp-eldoc-prefer-signature-help nil)
  (setq lsp-enable-links nil)
  (setq lsp-enable-file-watchers nil)
  (add-hook 'evil-insert-state-entry-hook (lambda () (setq-local lsp-hover-enabled nil)))
  (add-hook 'evil-insert-state-exit-hook (lambda () (setq-local lsp-hover-enabled t)))
  )

(after! lsp-clients
  ;; (remhash 'clangd lsp-clients)
  )

(use-package! lsp-treemacs
  :load-path "~/Dev/Emacs/lsp-treemacs")

(use-package! lsp-ui
  :load-path "~/Dev/Emacs/lsp-ui"
  :commands lsp-ui-mode
  :config
  (setq
   lsp-ui-sideline-enable nil
   lsp-ui-sideline-ignore-duplicate t
   lsp-ui-doc-header nil
   lsp-ui-doc-include-signature nil
   lsp-ui-doc-background (doom-color 'base4)
   lsp-ui-doc-border (doom-color 'fg)

   lsp-ui-peek-force-fontify nil
   lsp-ui-peek-expand-function (lambda (xs) (mapcar #'car xs)))

  (custom-set-faces
   '(ccls-sem-global-variable-face ((t (:underline t :weight extra-bold))))
   '(lsp-face-highlight-read ((t (:background "sea green"))))
   '(lsp-face-highlight-write ((t (:background "brown4"))))
   '(lsp-ui-sideline-current-symbol ((t (:foreground "grey38" :box nil))))
   '(lsp-ui-sideline-symbol ((t (:foreground "grey30" :box nil)))))

  ;; (map! :after lsp-ui-peek
  ;;       :map lsp-ui-peek-mode-map
  ;;       "h" #'lsp-ui-peek--select-prev-file
  ;;       "j" #'lsp-ui-peek--select-next
  ;;       "k" #'lsp-ui-peek--select-prev
  ;;       "l" #'lsp-ui-peek--select-next-file
  ;;       )

  ;; (defhydra hydra/ref (evil-normal-state-map "x")
  ;;   "reference"
  ;;   ("p" (-let [(i . n) (lsp-ui-find-prev-reference)]
  ;;          (if (> n 0) (message "%d/%d" i n))) "prev")
  ;;   ("n" (-let [(i . n) (lsp-ui-find-next-reference)]
  ;;          (if (> n 0) (message "%d/%d" i n))) "next")
  ;;   ("R" (-let [(i . n) (lsp-ui-find-prev-reference '(:role 8))]
  ;;          (if (> n 0) (message "read %d/%d" i n))) "prev read" :bind nil)
  ;;   ("r" (-let [(i . n) (lsp-ui-find-next-reference '(:role 8))]
  ;;          (if (> n 0) (message "read %d/%d" i n))) "next read" :bind nil)
  ;;   ("W" (-let [(i . n) (lsp-ui-find-prev-reference '(:role 16))]
  ;;          (if (> n 0) (message "write %d/%d" i n))) "prev write" :bind nil)
  ;;   ("w" (-let [(i . n) (lsp-ui-find-next-reference '(:role 16))]
  ;;          (if (> n 0) (message "write %d/%d" i n))) "next write" :bind nil)
  ;;   )
  )

(setq magit-repository-directories '(("~/Dev" . 2)))

(after! ivy
  (setq ivy-initial-inputs-alist nil)
  (push '(+ivy/switch-workspace-buffer) ivy-display-functions-alist)
  )
(after! ivy-hydra
  ;; Override ivy/autoload/hydras.el
  (define-key hydra-ivy/keymap "q" #'hydra-ivy/nil)
  )

(defvar +my/xref-blacklist nil
  "List of paths that should not enable xref-find-* or dumb-jump-go")

;;; Override
;; This function is transitively called by xref-find-{definitions,references,apropos}
(after! xref
  ;; This is required to make `xref-find-references' not give a prompt.
  ;; `xref-find-references' asks the identifier (which has no text property)
  ;; and then passes it to `lsp-mode', which requires the text property at
  ;; point to locate the references.
  ;; https://debbugs.gnu.org/cgi/bugreport.cgi?bug=29619
  (setq xref-prompt-for-identifier '(not xref-find-definitions
                                         xref-find-definitions-other-window
                                         xref-find-definitions-other-frame
                                         xref-find-references))
  )

(after! ivy-xref
  (push '(ivy-xref-show-xrefs . nil) ivy-sort-functions-alist))

(use-package! smart-forward)

(use-package! symbol-overlay
  :commands (symbol-overlay-put))

(use-package! rg)

(use-package! smartparens
  :config
  (setq sp-autoinsert-pair nil
        sp-autodelete-pair nil
        sp-escape-quotes-after-insert nil)
  (setq-default sp-autoskip-closing-pair nil)
  )

(use-package! tldr
  :commands (tldr)
  :config
  (setq tldr-directory-path (concat doom-etc-dir "tldr/"))
  (set-popup-rule! "^\\*tldr\\*" :side 'right :select t :quit t)
  )

(after! nav-flash
  ;; (defun nav-flash-show (&optional pos end-pos face delay)
  ;; ...
  ;; (let ((inhibit-point-motion-hooks t))
  ;; (goto-char pos)
  ;; (beginning-of-visual-line) ; work around args-out-of-range error when the target file is not opened
  (defun +advice/nav-flash-show (orig-fn &rest args)
    (ignore-errors (apply orig-fn args)))
  (advice-add 'nav-flash-show :around #'+advice/nav-flash-show))

(setq which-key-idle-delay 0)

(set-popup-rules! '(
  ("^\\*helpful" :size 0.4)
  ("^\\*info.*" :size 80 :size right)
  ("^\\*Man.*" :size 80 :side right)
  ))

;; TODO workaround emacsclient -nw a.cc
(advice-add #'+doom-dashboard|make-frame :override #'ignore)

(let ((profile "~/.config/doom/profile.el"))
  (when (file-exists-p profile)
    (load-file profile)))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(safe-local-variable-values
   '((eval c-set-offset 'innamespace 0)
     (whitespace-line-column . 80))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ccls-sem-global-variable-face ((t (:underline t :weight extra-bold))))
 '(lsp-face-highlight-read ((t (:background "sea green"))))
 '(lsp-face-highlight-write ((t (:background "brown4"))))
 '(lsp-ui-sideline-current-symbol ((t (:foreground "grey38" :box nil))))
 '(lsp-ui-sideline-symbol ((t (:foreground "grey30" :box nil)))))
