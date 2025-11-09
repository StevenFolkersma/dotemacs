;; Also read: <https://protesilaos.com/codelog/2022-05-13-emacs-elpa-devel/>
(setq package-archives
      '(("gnu-elpa" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa" . "https://melpa.org/packages/")))

;; Highest number gets priority (what is not mentioned has priority 0)
(setq package-archive-priorities
      '(("gnu-elpa" . 3)
        ("melpa" . 2)
        ("nongnu" . 1)))

(add-to-list 'display-buffer-alist
             '("\\`\\*\\(Warnings\\|Compile-Log\\)\\*\\'"
               (display-buffer-no-window)
               (allow-no-window . t)))

(add-to-list 'load-path "~/.config/emacs/steven")

(setq make-backup-files nil)
(setq backup-inhibited nil) ; Not sure if needed, given `make-backup-files'
(setq create-lockfiles nil)

;; Disable the damn thing by making it disposable.
(setq custom-file (make-temp-file "emacs-custom-"))
(load custom-file :no-error-if-file-is-missing)

(setq initial-buffer-choice t)
(setq initial-major-mode 'emacs-lisp-mode)
(setq-default inhibit-startup-screen t)
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t) 
(setq initial-scratch-message
""      
)

(defun steven/keyboard-quit-dwim ()
  "Do-What-I-Mean behaviour for a general `keyboard-quit'.

The generic `keyboard-quit' does not do the expected thing when
the minibuffer is open.  Whereas we want it to close the
minibuffer, even without explicitly focusing it.

The DWIM behaviour of this command is as follows:

- When the region is active, disable it.
- When a minibuffer is open, but not focused, close the minibuffer.
- When the Completions buffer is selected, close it.
- In every other case use the regular `keyboard-quit'."
  (interactive)
  (cond
   ((region-active-p)
    (keyboard-quit))
   ((derived-mode-p 'completion-list-mode)
    (delete-completion-window))
   ((> (minibuffer-depth) 0)
    (abort-recursive-edit))
   (t
    (keyboard-quit))))

(define-key global-map (kbd "C-g") #'steven/keyboard-quit-dwim)

(defun nano-kill ()
  "Delete frame or kill emacs if there is only one frame left"

  (interactive)
  (condition-case nil
      (delete-frame)
    (error (save-buffers-kill-terminal))))

(bind-key "C-x k" #'kill-current-buffer)
(bind-key "C-x C-c" #'nano-kill)
(bind-key "C-x C-r" #'recentf-open)
(bind-key "M-n" #'make-frame)
(bind-key "C-z"  nil) ;; No suspend frame
(bind-key "C-<wheel-up>" nil) ;; No text resize via mouse scroll
(bind-key "C-<wheel-down>" nil) ;; No text resize via mouse scroll

(global-set-key "\C-x\C-m" 'execute-extended-command)

(global-set-key "\C-c\C-m" 'execute-extended-command)

(global-set-key "\C-w" 'backward-kill-word)

(global-set-key "\C-c\C-k" 'kill-region)

(global-unset-key (kbd "C-x m"))

(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(blink-cursor-mode -1)
(global-hl-line-mode 1)
(pixel-scroll-precision-mode 1)
(set-default-coding-systems 'utf-8)
(setq-default indent-tabs-mode nil
              ring-bell-function 'ignore
              select-enable-clipboard t)

(defun steven/setup-fonts-linux ()
  (let ((mono-spaced-font "Roboto Mono")
        (proportionately-spaced-font "DejaVu Sans"))
    (set-face-attribute 'default nil :family mono-spaced-font :weight 'normal :height 180)
    (set-face-attribute 'fixed-pitch nil :family mono-spaced-font :height 1.0)
    (set-face-attribute 'variable-pitch nil :weight 'normal :family proportionately-spaced-font :height 1.1)))

(defun steven/setup-fonts-mac ()
  (let ((mono-spaced-font "Roboto Mono")
        (proportionately-spaced-font "DejaVu Sans"))
    (set-face-attribute 'default nil :family mono-spaced-font :weight 'thin :height 170)
    (set-face-attribute 'fixed-pitch nil :family mono-spaced-font :height 1.0)
    (set-face-attribute 'variable-pitch nil :weight 'normal :family proportionately-spaced-font :height 1.1)))

;; Run after Emacs initializes and after any theme is applied
(if (eq system-type 'darwin)
    ;; macOS-specific configuration
   (progn
    (add-hook 'after-init-hook #'steven/setup-fonts-mac)
    (add-hook 'after-load-theme-hook #'steven/setup-fonts-mac))
  ;; Non-macOS configuration
  (progn
   (add-hook 'after-init-hook #'steven/setup-fonts-linux)
   (add-hook 'after-load-theme-hook #'steven/setup-fonts-linux)))

(set-display-table-slot standard-display-table 'truncation (make-glyph-code ?…))
(set-display-table-slot standard-display-table 'wrap (make-glyph-code ?–))

(defun nano-theme-set-light ()
  "Apply light Nano theme base."
  ;; Colors from Material design at https://material.io/
  (setq frame-background-mode    'light)
  (setq nano-color-foreground "#37474F") ;; Blue Grey / L800
  (setq nano-color-background "#FFFFFF") ;; White
  (setq nano-color-highlight  "#ECEFF1") ;; Very Light Grey
  (setq nano-color-critical   "#FF6F00") ;; Amber / L900
  (setq nano-color-salient    "#673AB7") ;; Deep Purple / L500
  (setq nano-color-strong     "#000000") ;; Black
  (setq nano-color-popout     "#FFAB91") ;; Deep Orange / L200
  (setq nano-color-subtle     "#ECEFF1") ;; Blue Grey / L50
  (setq nano-color-faded      "#B0BEC5") ;; Blue Grey / L200
  ;; to allow for toggling of the themes.
  (setq nano-theme-var "light")
  )

(defun nano-theme-set-dark ()
  "Apply dark Nano theme base."
  ;; Colors from Nord theme at https://www.nordtheme.com
  (setq frame-background-mode     'dark)
  (setq nano-color-foreground "#ECEFF4") ;; Snow Storm 3  / nord  6
  (setq nano-color-background "#2E3440") ;; Polar Night 0 / nord  0
  (setq nano-color-highlight  "#3B4252") ;; Polar Night 1 / nord  1
  (setq nano-color-critical   "#EBCB8B") ;; Aurora        / nord 11
  (setq nano-color-salient    "#81A1C1") ;; Frost         / nord  9
  (setq nano-color-strong     "#ECEFF4") ;; Snow Storm 3  / nord  6
  (setq nano-color-popout     "#D08770") ;; Aurora        / nord 12
  (setq nano-color-subtle     "#434C5E") ;; Polar Night 2 / nord  2
  (setq nano-color-faded      "#677691") ;;
  ;; to allow for toggling of the themes.
  (setq nano-theme-var "dark")
  )

(require 'nano-base-colors)
  (require 'nano-faces)
  (require 'nano-modeline)
  (require 'nano-theme)
;  (require 'nano-theme-dark)
;  (require 'nano-theme-light)

  (cond                                                       
   ((member "-default" command-line-args) t)                  
   ((member "-dark" command-line-args) (nano-theme-set-dark)) 
   (t (nano-theme-set-light)))                                
  (call-interactively 'nano-refresh-theme)

(use-package nerd-icons
  :ensure t)

(use-package nerd-icons-completion
  :ensure t
  :after marginalia
  :config
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package nerd-icons-corfu
  :ensure t
  :after corfu
  :config
  (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package nerd-icons-dired
  :ensure t
  :hook
  (dired-mode . nerd-icons-dired-mode))

(setq display-line-numbers-type t)
;;(fringe-mode 1)
(setq default-frame-alist
   '((width  . 72) (left-fringe . 0) (right-fringe . 0)
    (internal-border-width . 32) (vertical-scroll-bars . nil)
    (bottom-divider-width . 0) (right-divider-width . 32)
    (undecorated-round . t)))
(modify-frame-parameters nil default-frame-alist)
(setq-default pop-up-windows nil)

;; different setting for GNOME

(if (eq system-type 'darwin)
    ;; macOS-specific configuration
    (set-frame-parameter nil 'undecorated-round t)
  ;; Non-macOS configuration
  (set-frame-parameter nil 'undecorated nil))

(setq-default fill-column 80)
;;(global-visual-line-mode 1)
;; set visual-line-mode only with text
(add-hook 'text-mode-hook 'visual-line-mode) 
(add-hook 'text-mode-hook 'visual-wrap-prefix-mode)

(defun center-frame ()
  "Center the current frame on the display."
  (let* ((frame (selected-frame))
         (frame-w (frame-pixel-width frame))
         (frame-h (frame-pixel-height frame))
         (display-w (display-pixel-width))
         (display-h (display-pixel-height))
         (pos-x (/ (- display-w frame-w) 2))
         (pos-y (/ (- display-h frame-h) 2)))
    (set-frame-position frame (max pos-x 0) (max pos-y 0))))

;; Hook into startup
(add-hook 'window-setup-hook #'center-frame)

(defun steven/toggle-frame-width ()
  "Toggle the frame width between narrow and wide, and adjust height to fit display."
  (interactive)
  (let* ((frame (selected-frame))
         (current-width (frame-width frame))
         (narrow-width 72)
         (wide-width 135)
         (char-height (frame-char-height frame))
         (display-height (display-pixel-height))
         (usable-height (- display-height 40)) 
         (frame-rows (/ usable-height char-height)))
    (set-frame-height frame frame-rows)
    (set-frame-width frame (if (> current-width narrow-width)
                               narrow-width
                             wide-width)))
    (center-frame))

(global-set-key (kbd "C-c t w") 'steven/toggle-frame-width)

(use-package delsel
  :ensure nil
  :hook (after-init . delete-selection-mode))

(use-package trashed
  :ensure t
  :commands (trashed)
  :config
  (setq trashed-action-confirmer 'y-or-n-p)
  (setq trashed-use-header-line t)
  (setq trashed-sort-key '("Date deleted" . t))
  (setq trashed-date-format "%Y-%m-%d %H:%M:%S"))

(use-package dired
    :ensure nil
    :commands (dired)
    :hook
    ((dired-mode . dired-hide-details-mode)
     (dired-mode . hl-line-mode)
     (dired-mode . dired-omit-mode))
    :config
    (setq dired-recursive-copies 'always)
    (setq dired-recursive-deletes 'always)
    (setq delete-by-moving-to-trash t)
    (setq dired-dwim-target t)
    (setq dired-listing-switches "-alh --group-directories-first")
    (use-package dired-x
       :ensure nil  ;; also built-in
       :config
       (setq dired-omit-files
            (concat dired-omit-files
             "\\|^\\.DS_Store$"
             "\\|^\\.stfolder$"
             "\\|^\\.localized$"))))

(defun steven/dired-layout ()
  "Custom behaviors for dired layout."
  ;;truncate-lines is buffer local, so can be safely changed
  (setq truncate-lines t))

;; The above does not work because the 'hide details
;; mode' is also hooked to dired mode and overrides my
;; settings. Check C-h v dired-mode-hook.

;; The following appends it to the hook list at the end
(add-hook 'dired-mode-hook
          #'steven/dired-layout
          t)

(use-package dired-subtree
  :ensure t
  :after dired
  :bind
  ( :map dired-mode-map
    ("<tab>" . dired-subtree-toggle)
    ("TAB" . dired-subtree-toggle)
    ("<backtab>" . dired-subtree-remove)
    ("S-TAB" . dired-subtree-remove))
  :config
  (setq dired-subtree-use-backgrounds nil))

(use-package dired-preview
    :ensure t
    :config
    (setq dired-preview-delay 0.7)
    (setq dired-preview-max-size (expt 2 20))
    (setq dired-preview-ignored-extensions-regexp
          (concat "\\."
                  "\\(gz\\|"
                  "zst\\|"
                  "tar\\|"
                  "xz\\|"
                  "rar\\|"
                  "zip\\|"
                  "iso\\|"
                  "epub"
                  "\\)")))

(use-package colorful-mode
  ;; :diminish
  :ensure t ; Optional
  :custom
  (colorful-use-prefix t)
  (colorful-prefix-string " ")
  (colorful-only-strings 'only-prog)
  (css-fontify-colors nil)
  :config
  (global-colorful-mode t)
  (add-to-list 'global-colorful-modes 'helpful-mode))

;; Set the default server to dict.org (avoids prompting each time)
(setq dictionary-server "dict.org")

;; Optional: Set default dictionary to GCIDE for Webster's 1913
(setq dictionary-default-dictionary "gcide")

;; Optional: Bind a key for quick lookups (e.g., on the current word at point)
(global-set-key (kbd "C-c d") #'dictionary-search)

;; Use Hunspell as the spell-checker
(when (executable-find "hunspell")
  (setq-default ispell-program-name "hunspell")
  (setq ispell-really-hunspell t))

;; Default to Dutch
(setq ispell-dictionary "nl_NL")
(setq flyspell-default-dictionary "nl_NL")

;; Tell Emacs where to find the dictionaries (optional if auto-detected)
(setq ispell-local-dictionary-alist
      '(("en_GB" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "en_GB") nil utf-8)
        ("nl_NL" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "nl_NL") nil utf-8)))

;(add-hook 'text-mode-hook 'flyspell-mode)

(defun steven/toggle-spell-language ()
  "Toggle between English and Dutch Hunspell dictionaries."
  (interactive)
  (let ((current-dict ispell-current-dictionary))
    (cond
     ((string= current-dict "en_GB")
      (ispell-change-dictionary "nl_NL")
      (message "Switched dictionary to Dutch (nl_NL)"))
     ((string= current-dict "nl_NL")
      (ispell-change-dictionary "en_GB")
      (message "Switched dictionary to English (en_GB)"))
     (t
      (ispell-change-dictionary "en_GB")
      (message "Defaulted dictionary to English (en_GB)"))))
     (flyspell-buffer))

;; Enable electric-indent-mode globally
(electric-indent-mode -1)
(electric-pair-mode -1)
(electric-quote-mode -1)

(use-package vertico
  :ensure t
  :config
  (setq vertico-cycle t)
  (setq vertico-resize  nil)
  :hook (after-init . vertico-mode))

(use-package marginalia
  :ensure t
  :hook (after-init . marginalia-mode))

(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless basic))
  (setq completion-category-defaults nil)
  (setq completion-category-overrides nil))

(use-package consult
  :ensure t
  :bind (;; A recursive grep
         ("M-s M-g" . consult-grep)
         ;; Search for files names recursively
         ("M-s M-f" . consult-find)
         ;; Search through the outline (headings) of the file
         ("M-s M-o" . consult-outline)
         ;; Search the current buffer
         ("M-s M-l" . consult-line)
         ;; Switch to another buffer, or bookmarked file, or recently
         ;; opened file.
         ("C-x C-b" . consult-buffer))
   :config
   (setq consult-buffer-sources
      '(consult--source-hidden-buffer
        consult--source-buffer
        consult--source-bookmark
        ;; consult--source-recent-file   ; ← disable recent files
        ))
   (setq consult-preview-key 'any)
   (consult-customize consult-find 
                   :state (consult--file-preview))
   (consult-customize consult-fd 
                   :state (consult--file-preview))) ;; Preview every candidate as you move)

(use-package consult-notes
  :ensure t
  :commands (consult-notes
             consult-notes-search-in-all-notes)
  :config
  (setq consult-notes-file-dir-sources '(("Huiswiki" ?h "~/Documents/Huiswiki/")
                                         ("Systemwiki" ?s "~/Documents/Systemwiki")))
  (setq consult-notes-org-headings-files '("~/Documents/Org/general.org"
                                           "~/Documents/Org/main.org"))
  (consult-notes-org-headings-mode)
  (when (locate-library "denote")
    (consult-notes-denote-mode)))

(use-package consult-dir
  :ensure t
  :bind (("C-x C-d" . consult-dir)
         :map minibuffer-local-completion-map
         ("C-x C-d" . consult-dir)
         ("C-x C-j" . consult-dir-jump-file))
  :config
  (setq consult-dir-default-command #'consult-find))

;;; Extended minibuffer actions and more (embark.el)

(use-package embark
  :ensure t
  :bind
  ( :map minibuffer-local-map
    ("C-c C-c" . embark-collect)
    ("C-c C-e" . embark-export)))

;; Needed for correct exporting while using Embark with Consult
;; commands.
(use-package embark-consult
  :ensure t
  :after (embark consult))

(use-package savehist
  :ensure nil ; it is built-in
  :hook (after-init . savehist-mode))

(use-package savehist
  :ensure nil ; it is built-in
  :hook (after-init . recentf-mode))

;; Redirect auto-saves
(setq auto-save-file-name-transforms
      `((".*" "~/.config/emacs/auto-saves/\\1" t)))

(use-package corfu
  :ensure t
  :hook (after-init . global-corfu-mode)
  :bind (:map corfu-map ("<tab>" . corfu-complete))
  :config
  (setq tab-always-indent 'complete)
  (setq corfu-preview-current nil)
  (setq corfu-min-width 20)

  (setq corfu-popupinfo-delay '(1.25 . 0.5))
  (corfu-popupinfo-mode 1) ; shows documentation after `corfu-popupinfo-delay'

  ;; Sort by input history (no need to modify `corfu-sort-function').
  (with-eval-after-load 'savehist
    (corfu-history-mode 1)
    (add-to-list 'savehist-additional-variables 'corfu-history)))

(use-package denote
  :ensure t
  :hook
  ;; If you use Markdown or plain text files you want to fontify links
  ;; upon visiting the file (Org renders links as buttons right away).
  ((text-mode . denote-fontify-links-mode-maybe)
   ;; Highlight Denote file names in Dired buffers.  Below is the
   ;; generic approach, which is great if you rename files Denote-style
   ;; in lots of places as I do.
   ;;
   ;; If you only want the `denote-dired-mode' in select directories,
   ;; then modify the variable `denote-dired-directories' and use the
   ;; following instead:
   ;;
   ;;  (dired-mode . denote-dired-mode-in-directories)
   (dired-mode . denote-dired-mode))
  :bind
  ;; Denote DOES NOT define any key bindings.  This is for the user to
  ;; decide.  Here I only have a subset of what Denote offers.
  ( :map global-map
    ("C-c n n" . denote)
    ("C-c n N" . denote-type)
    ("C-c n d" . denote-sort-dired)
    ;; Note that `denote-rename-file' can work from any context, not
    ;; just Dired buffers.  That is why we bind it here to the
    ;; `global-map'.
    ;;
    ;; Also see `denote-rename-file-using-front-matter' further below.
    ("C-c n r" . denote-rename-file)
    ;; If you intend to use Denote with a variety of file types, it is
    ;; easier to bind the link-related commands to the `global-map', as
    ;; shown here.  Otherwise follow the same pattern for
    ;; `org-mode-map', `markdown-mode-map', and/or `text-mode-map'.
    :map org-mode-map
     ("C-c n i" . denote-link) ; "insert" mnemonic
     ("C-c n I" . denote-add-links)
     ("C-c n b" . denote-backliNks)
     ("C-c n R" . denote-rename-file-using-front-matter)
    ;; Key bindings specifically for Dired.
    :map dired-mode-map
    ("C-c C-d C-i" . denote-dired-link-marked-notes)
    ("C-c C-d C-r" . denote-dired-rename-marked-files)
    ("C-C C-d C-k" . denote-dired-rename-marked-files-with-keywords)
    ("C-c C-d C-f" . denote-dired-rename-marked-files-using-front-matter))
  :config
  ;; Remember to check the doc strings of those variables.
  (setq denote-directory "~/Documents/Notes" )

  ;; If you want to have a "controlled vocabulary" of keywords,
  ;; meaning that you only use a predefined set of them, then you want
  ;; `denote-infer-keywords' to be nil and `denote-known-keywords' to
  ;; have the keywords you need.
  (setq denote-known-keywords '("emacs" "idea" "note" "recipe" "bikes" "config"))
  (setq denote-infer-keywords t)
  (setq denote-sort-keywords t)
  (setq denote-buffer-name-prefix "[D] ") ; to identify all Denote buffers
  (setq denote-rename-buffer-format "%D")
  (denote-rename-buffer-mode 1))

(use-package consult-denote
  :ensure t
  :bind
  (("C-c n f" . consult-denote-find)
   ("C-c n g" . consult-denote-grep))
  :config
  (consult-denote-mode 1))

(use-package denote-org
  :ensure t
  :commands
  ;; I list the commands here so that you can discover them more
  ;; easily.  You might want to bind the most frequently used ones to
  ;; the `org-mode-map'.
  ( denote-org-link-to-heading
    denote-org-backlinks-for-heading

    denote-org-extract-org-subtree

    denote-org-convert-links-to-file-type
    denote-org-convert-links-to-denote-type

    denote-org-dblock-insert-files
    denote-org-dblock-insert-links
    denote-org-dblock-insert-backlinks
    denote-org-dblock-insert-missing-links
    denote-org-dblock-insert-files-as-headings))

(use-package denote-silo
  :ensure t
  ;; Bind these commands to key bindings of your choice.
  :commands ( denote-silo-create-note
              denote-silo-open-or-create
              denote-silo-select-silo-then-command
              denote-silo-dired
              denote-silo-cd )
  :config
  ;; Add your silos to this list.  By default, it only includes the
  ;; value of the variable `denote-directory'.
  (setq denote-silo-directories
        (list denote-directory
              "~/Documents/Notes/"
              "~/Documents/Huiswiki/"
              "~/Documents/Recipebook/"
              "~/Documents/Bikes/"
              "~/Documents/Systemwiki/")))

(use-package denote-journal
  :ensure t
  ;; Bind those to some key for your convenience.
  :commands ( denote-journal-new-entry
              denote-journal-new-or-existing-entry
              denote-journal-link-or-create-entry )
  :hook (calendar-mode . denote-journal-calendar-mode)
  :config
  ;; Use the "journal" subdirectory of the `denote-directory'.  Set this
  ;; to nil to use the `denote-directory' instead.
  (setq denote-journal-directory
        (expand-file-name "Journal" denote-directory))
  ;; Default keyword for new journal entries. It can also be a list of
  ;; strings.
  (setq denote-journal-keyword "journal")
  ;; Read the doc string of `denote-journal-title-format'.
  (setq denote-journal-title-format 'day-date-month-year))

;;; Org-mode (personal information manager)
(use-package org
  :ensure nil
  :init
  (setq org-directory (expand-file-name "~/Documents/Org/"))
  (setq org-agenda-files (list "main.org" "general.org" "emacstodo.org")) 
  (setq org-agenda-skip-scheduled-if-done t)
  (setq org-imenu-depth 7)

  (add-to-list 'safe-local-variable-values '(org-hide-leading-stars . t))
  (add-to-list 'safe-local-variable-values '(org-hide-macro-markers . t))
  :bind
  ( :map global-map
    ("C-c l" . org-store-link)
    ("C-c o" . org-open-at-point-global)
    :map org-mode-map
    ;; I don't like that Org binds one zillion keys, so if I want one
    ;; for something more important, I disable it from here.
    ("C-c M-l" . org-insert-last-stored-link)
    ("C-c C-M-l" . org-toggle-link-display)
    ("M-." . org-edit-special) ; alias for C-c ' (mnenomic is global M-. that goes to source)
    :map org-src-mode-map
    ("M-," . org-edit-src-exit) ; see M-. above
    :map narrow-map
    ("b" . org-narrow-to-block)
    ("e" . org-narrow-to-element)
    ("s" . org-narrow-to-subtree))

  ;;;; general settings
  :config
  (setq org-refile-targets '((org-agenda-files :maxlevel . 1)))
  (setq org-hide-emphasis-markers t)
  (setq org-hide-leading-stars nil)
  (setq org-ellipsis "")
  (setq org-cycle-separator-lines 1) ;;number of seperator lines between collapsed headings
  (setq org-structure-template-alist
	'(("s" . "src")
	  ("e" . "src emacs-lisp")
	  ("E" . "src emacs-lisp :results value code :lexical t")
	  ("t" . "src emacs-lisp :tangle FILENAME")
	  ("x" . "example")
	  ("X" . "export")
	  ("q" . "quote")))
  (setq org-fold-catch-invisible-edits 'show) ;; what happens when you edit in a folded block
  (setq org-loop-over-headlines-in-active-region 'start-level)
  (setq org-modules '(ol-info ol-eww))
  (setq org-insert-heading-respect-content t)
  (setq org-highlight-latex-and-related nil) ; other options affect elisp regexp in src blocks
  (setq org-fontify-quote-and-verse-blocks t)
  (setq org-fontify-whole-block-delimiter-line t)
  (setq org-priority-faces nil)
  (setq org-log-done 'time)
  (setq org-table-convert-region-max-lines 20000)
  (setq org-todo-keywords        ; This overwrites the default Doom org-todo-keywords
	'((sequence
	   "TODO(t)"           ; A task that is ready to be tackled
	   "IDEA(i)"           ; An idea, not urgent
	   "READ(b)"            ; To read, not urgent
	   "LATER(w)"           ; Not urgent, might do later
	   "|"                 ; The pipe necessary to separate "active" states and "inactive" states
	   "DONE(d)"           ; Task has been completed
	   "ARCHIVED(a)" )))
  )

(use-package org-modern
  :ensure t
  :after org
  :config
  ;; Use custom symbols for heading stars
  (setq org-modern-star '("" "" "" "" "" ""))

  ;; Hide the original asterisks
  (setq org-modern-hide-stars nil)

  ;; Keep indentation reasonable
  (setq org-indent-indentation-per-level 2)

  ;; Disable other org-modern features
  (setq org-modern-table nil)
  (setq org-modern-list nil)
  (setq org-modern-block-name nil)
  (setq org-modern-checkbox nil)
  (setq org-modern-priority nil)
  (setq org-modern-tag nil)
  (setq org-modern-timestamp nil)
  (setq org-modern-keyword nil)
  (setq org-modern-todo nil)
  (setq org-modern-horizontal-rule nil))

(add-hook 'org-modern-mode-hook
          (lambda ()
            (setq org-hide-leading-stars org-modern-mode)))

(use-package org-capture
     :ensure nil
     :bind ("C-c c" . org-capture)
     :config

     (setq org-capture-templates
           `(("e" "Emacs Inbox" entry
              (file+headline "emacstodo.org" "Inbox")
              ,(concat "* %^{Title}\n"
                       ":PROPERTIES:\n"
                       ":CAPTURED: %U\n"
                       ":CUSTOM_ID: h:%(format-time-string \"%Y%m%dT%H%M%S\")\n"
                       ":END:\n\n"
                       "%a\n%i%?\m")
              :empty-lines-after 1)
 	    ("i" "Inbox" entry
              (file+headline "general.org" "Inbox")
              ,(concat "* %^{Title}\n"
                       ":PROPERTIES:\n"
                       ":CAPTURED: %U\n"
                       ":CUSTOM_ID: h:%(format-time-string \"%Y%m%dT%H%M%S\")\n"
                       ":END:\n\n"
                       "%a\n%i%?\n")
              :empty-lines-after 1)
             ("r" "To Read" entry
              (file+olp "general.org" "To Read")
              ,(concat "* %^{Title} %^g\n"
                       ":PROPERTIES:\n"
                       ":CAPTURED: %U\n"
                       ":CUSTOM_ID: h:%(format-time-string \"%Y%m%dT%H%M%S\")\n"
                       ":END:\n\n"
                       "%a\n%?\n")
              :empty-lines-after 1))))

(defun steven/recipe-template ()
  "Insert my Org recipe template."
  (interactive)
  (insert
   (concat
    "* Title\n\n"
    "** Info\n"
    "Categorie: Maaltijden|Ontbijt\n"
    "Bron:\n"
    "Pagina:\n"
    "Bereidingstijd:\n"
    "Personen:\n\n"
    "** Ingrediënten\n"
    "- [ ]\n"
    "- [ ]\n\n"
    "** Bereiding\n"
    "1. ")))

(org-babel-do-load-languages
  'org-babel-load-languages
  '((emacs-lisp . t)
    (python     . t)
    (shell      . t)))

(setq org-confirm-babel-evaluate
    (lambda (lang body)
      (not (member lang '("emacs-lisp" "python" "shell" "yaml" )))))

(use-package org-cliplink
  :ensure t
  :commands (org-cliplink)
  :after org
  :bind (:map org-mode-map
         ("C-c l" . org-cliplink)))

(use-package elfeed
        :ensure t
        :hook
        (elfeed-show-mode . visual-line-mode)
        :bind
        ("C-c e" . elfeed)
        :config
        (load-file "~/.config/emacs/elfeed-feeds.el")
        )

(require 'elfeed)

(defun nano-elfeed-entry (title subtitle date tags unread &optional no-newline)
  (let* ((foreground-color (if unread
                               (face-foreground 'default)
                             (face-foreground 'font-lock-comment-face nil t)))
         (background-color (face-background 'highlight))
         (border-color     (face-background 'default))
         (face-upper    `(:foreground ,foreground-color
                          :background ,background-color
                          :overline ,border-color))
         (face-title    `(:foreground ,foreground-color
                          :background ,background-color
                          :weight ,'bold
                          :overline ,border-color))
         (face-subtitle `(:foreground ,foreground-color
                          :background ,background-color
                          :family "Roboto Mono"
                          :height 170
                          :underline nil
                          ))
         (face-lower    `(:foreground ,foreground-color
                          :background ,background-color
                          :underline nil
                          ))
         (window-width (window-width))
         (title-max-width (- window-width 10))
         (indicator  (if unread "  " "  ")))
    (insert
            (propertize indicator 'face face-title)
            (propertize (truncate-string-to-width subtitle title-max-width nil nil "...") 'face face-title 'elfeed-entry t)
            (propertize " " 'display "\n"))
    (insert "   " 
            (propertize title 'face face-upper)
            " | "
            (propertize date 'face face-subtitle)
            " | "
            (propertize (string-join tags " ") 'face 'elfeed-search-tag-face))
     ))

(defun nano-elfeed-search-print-entry (entry)
  "Alternative printing of elfeed entries using SVG tags."

  (let* ((date (elfeed-search-format-date (elfeed-entry-date entry)))
         (title (or (elfeed-meta entry :title)
                    (elfeed-entry-title entry) ""))
         (unread (member 'unread (elfeed-entry-tags entry)))
         (tags (mapcar #'symbol-name (elfeed-entry-tags entry)))
         (feed (elfeed-entry-feed entry))
         (feed-title (when feed
                       (or (elfeed-meta feed :title)
                           (elfeed-feed-title feed)))))

    (nano-elfeed-entry feed-title title date tags  unread t)) )

(defun nano-elfeed-search-mode ()
  (setq left-fringe-width 0
        right-fringe-width 0
        left-margin-width 0
        right-margin-width 0)
  (set-window-buffer nil (current-buffer))

  (setq hl-line-overlay-priority 100)
  (hl-line-mode -1)
  (setq cursor-type nil)
  (face-remap-add-relative 'hl-line :inherit 'nano-faded-i)
  (hl-line-mode t)
  )

(defun nano-elfeed-show-mode ()
  (visual-line-mode)
;;  (setq truncate-lines t)
  (let ((inhibit-read-only t)
        (inhibit-modification-hooks t))
    (setq-local truncate-lines nil)
    (setq-local shr-width 79)
    ;; (setq header-line-format nil)
    ;; (face-remap-set-base 'default '(:height 140))
    (set-buffer-modified-p nil)))

(defun nano-elfeed-next-entry ()
  (interactive)
  (text-property-search-forward 'elfeed-entry t))

(defun nano-elfeed-prev-entry ()
  (interactive)
  (text-property-search-backward 'elfeed-entry t))

(defun nano-elfeed-show-next ()
  "Show the next item in the elfeed-search buffer."
  (interactive)
  (funcall elfeed-show-entry-delete)
  (with-current-buffer (elfeed-search-buffer)
    (when elfeed-search-remain-on-entry
      (nano-elfeed-next-entry))
    (call-interactively #'elfeed-search-show-entry)))

(defun nano-elfeed-show-prev ()
  "Show the previous item in the elfeed-search buffer."
  (interactive)
  (funcall elfeed-show-entry-delete)
  (with-current-buffer (elfeed-search-buffer)
    (when elfeed-search-remain-on-entry (forward-line 1))
    (nano-elfeed-prev-entry)
    (call-interactively #'elfeed-search-show-entry)))

(setq elfeed-search-filter "@2-weeks-ago +unread +news"          
      elfeed-search-print-entry-function
           #'nano-elfeed-search-print-entry)

(bind-key "<down>" #'nano-elfeed-next-entry 'elfeed-search-mode-map)
(bind-key "n" #'nano-elfeed-next-entry 'elfeed-search-mode-map)

(bind-key "<up>" #'nano-elfeed-prev-entry 'elfeed-search-mode-map)
(bind-key "p" #'nano-elfeed-prev-entry 'elfeed-search-mode-map)

(bind-key "p" #'elfeed-show-prev 'elfeed-show-mode-map)
(bind-key "n" #'nano-elfeed-show-next 'elfeed-show-mode-map)

;(add-hook 'elfeed-search-mode-hook #'nano-elfeed-search-mode)
;(add-hook 'elfeed-show-mode-hook #'nano-elfeed-show-mode)

(defun steven/elfeed-eww-readable ()
   "Open current elfeed entry in eww with readable mode."
   (interactive)
   (let ((link (elfeed-entry-link (elfeed-search-selected :single))))
     (eww link)
     (add-hook 'eww-after-render-hook #'eww-readable nil t)))

;; (define-key elfeed-search-mode-map (kbd "e") 'steven/elfeed-eww-readable)

(defun steven/elfeed-play-with-mpv ()
     "Play entry link with mpv."
     (interactive)
     (let ((entry (if (eq major-mode  'elfeed-show-mode) elfeed-show-entry (elfeed-search-selected :ignore-region))))
          (when entry 
             (message "Opening %s with mpv..." (elfeed-entry-link entry))
             (start-process "elfeed-mpv" nil "mpv" (elfeed-entry-link entry)))))

;; (define-key elfeed-search-mode-map (kbd "v") 'steven/elfeed-play-with-mpv)
;; (define-key elfeed-show-mode-map (kbd "v") 'steven/elfeed-play-with-mpv)

(use-package which-key
  :ensure nil ; built into Emacs 30
  :hook (after-init . which-key-mode)
  :config
  (setq which-key-separator "  ")
  (setq which-key-prefix-prefix "... ")
  (setq which-key-max-display-columns 3)
  (setq which-key-idle-delay 1.5)
  (setq which-key-idle-secondary-delay 0.25)
  (setq which-key-add-column-padding 1)
  (setq which-key-max-description-length 40))

;;; Frame-isolated buffers
;; Another package of mine.  Read the manual:
;; <https://protesilaos.com/emacs/beframe>.

(require 'beframe)

;; This is the default value.  Write here the names of buffers that
;; should not be beframed.
(setq beframe-global-buffers '("*scratch*" "*Messages*" "*Backtrace*"))

(beframe-mode 1)

;; Bind Beframe commands to a prefix key, such as C-c b:
(define-key global-map (kbd "C-c b") #'beframe-prefix-map)
;; OR use the transient instead of the prefix map:
(define-key global-map (kbd "C-c b") #'beframe-transient)

;;; Notmuch (mail indexer and mail user agent (MUA))

;; I installed notmuch from the distro's repos because the CLI program is
;; not dependent on Emacs.  Though the package also includes notmuch.el
;; which is what we use here (they are maintained by the same people).
(use-package notmuch
  :load-path "/usr/local/share/emacs/site-lisp/notmuch/"
  :defer t
  :commands (notmuch notmuch-mua-new-mail)
  :config
   (setq notmuch-saved-searches
      '((:name "inbox" :query "tag:inbox" :key [105] :sort-order newest-first :search-type nil)
       (:name "unread" :query "tag:unread" :key [117] :sort-order newest-first)
       (:name "flagged" :query "tag:flagged" :key [102] :sort-order newest-first)
       (:name "sent" :query "tag:sent" :key [116] :sort-order newest-first)
       (:name "drafts" :query "tag:draft" :key [100] :sort-order newest-first)
       (:name "Winkels" :query "folder:\"Folders/🏬 Winkels\"" :sort-order newest-first :count-query "tag:unread")
       (:name "Gmail" :query "folder:\"Folders/✉️ Gmail\"" :sort-order newest-first :count-query "tag:unread and folder:\"Folders/✉️ Gmail\"")
       (:name "Tijdelijk" :query "folder:\"Folders/⏱️ Tijdelijk\"" :sort-order newest-first :count-query "tag:unread")
       (:name "🧔🏻‍♂️ Persoonlijk" :query "folder:\"Folders/🧔🏻‍♂️ Persoonlijk\"" :sort-order newest-first :count-query "tag:unread")
       (:name "🗞️ Newsletters" :query "folder:\"Folders/🗞️ Newsletters\"" :sort-order newest-first :count-query "tag:unread")
       (:name "❤️‍🩹 Zorg" :query "folder:\"Folders/❤️‍🩹 Zorg\"" :sort-order newest-first :count-query "tag:unread")
       (:name "🏡 Huishouden" :query "folder:\"Folders/🏡 Huishouden\"" :sort-order newest-first :count-query "tag:unread")
       (:name "📰 Accounts" :query "folder:\"Folders/📰 Accounts\"" :sort-order newest-first :count-query "tag:unread"))))

(use-package ol-notmuch
  :ensure t
  :after notmuch)

(defun my-notmuch-bookmark-jump (bookmark)
  "Jump to a notmuch saved search bookmark."
  (let ((search (bookmark-prop-get bookmark 'notmuch-search)))
    (notmuch-search search)))

(defun my-notmuch-bookmark-set ()
  "Set a bookmark for the current notmuch search buffer."
  (interactive)
  (unless (derived-mode-p 'notmuch-search-mode)
    (user-error "Not in a notmuch search buffer"))
  (let* ((name (read-string "Bookmark name: "))
         ;; Evaluate the variable, don't quote it
         (search notmuch-search-query-string)
         ;; Build the bookmark record
         (bookmark (list (cons 'notmuch-search search)
                         (cons 'handler #'my-notmuch-bookmark-jump))))
    ;; Store it properly
    (bookmark-store name bookmark nil)
    (message "Stored notmuch search bookmark: %s (%s)" name search)))

;;; Interactive and powerful git front-end (Magit)
(use-package transient
  :ensure t
  :config
  (setq transient-show-popup 0.5))

(use-package magit
  :ensure t
  :bind
  ( :map global-map
    ("C-c g" . magit-status))
  :init
  (setq magit-section-visibility-indicator '(magit-fringe-bitmap> . magit-fringe-bitmapv))
  :config
  (setq git-commit-summary-max-length 50)
  ;; NOTE 2023-01-24: I used to also include `overlong-summary-line'
  ;; in this list, but I realised I do not need it.  My summaries are
  ;; always in check.  When I exceed the limit, it is for a good
  ;; reason.
  (setq git-commit-style-convention-checks '(non-empty-second-line))

  (setq magit-diff-refine-hunk t)

  ;; Show icons for files in the Magit status and other buffers.
  (with-eval-after-load 'magit
    (setq magit-format-file-function #'magit-format-file-nerd-icons)))

(use-package biome
  :ensure t
  :bind
  :config
   (setq biome-query-coords
      '(("Eindhoven" 51.43531 5.526096)
        ("Groningen" 53.21962, 6.56706)
        ("Belo Horizonte" -19.91968, -43.94013)))
   (add-to-list 'biome-presets-alist
             '("biome-query-preset-101" :normal
               ((:name . "Weather Forecast") (:group . "daily")
                (:params
                 ("daily" "sunshine_duration" "precipitation_sum"
                  "temperature_2m_min" "temperature_2m_max")
                 ("past_days" . 2) ("forecast_days" . 6)
                 ("longitude" . 5.526096) ("latitude" . 51.43531)
                 ("timezone" . "CET")))))
   ;;Invoke with M-x biome-preset
)

(defvar center-document-desired-width 80
  "The desired width of a document centered in the window.")

(defun center-document--adjust-margins ()
  ;; Reset margins first before recalculating
  (set-window-parameter nil 'min-margins nil)
  (set-window-margins nil nil)

  ;; Adjust margins if the mode is on
(when center-document-mode
    (let ((margin-width (max 0
                             (truncate
                              (/ (- (window-width)
                                    center-document-desired-width)
                                 2.0)))))
      (when (> margin-width 0)
        (set-window-parameter nil 'min-margins '(0 . 0))
        (set-window-margins nil margin-width margin-width)))))

(define-minor-mode center-document-mode
  "Toggle centered text layout in the current buffer."
  :lighter " Centered"
  :group 'editing
  (if center-document-mode
      (add-hook 'window-configuration-change-hook #'center-document--adjust-margins 'append 'local)
    (remove-hook 'window-configuration-change-hook #'center-document--adjust-margins 'local))
  (center-document--adjust-margins))

(use-package show-font
  :ensure t
  :bind
  (("C-c s f" . show-font-select-preview)
   ("C-c s t" . show-font-tabulated)))
