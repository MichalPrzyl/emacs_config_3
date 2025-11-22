;; This buffer is for text that is not saved, and for Lisp evaluation.
;; To create a file, visit it with ‘C-x C-f’ and enter text in its buffer.

(add-to-list 'load-path "~/.emacs.d/lisp/")
(load-theme 'gruber-darker t)


;; Wyłącz GUI paski i zbędne dekoracje
(menu-bar-mode -1)    ;; Górne menu (File, Edit itd.)
(tool-bar-mode -1)    ;; Pasek narzędzi z ikonami
(scroll-bar-mode -1)  ;; Pionowy pasek przewijania

;; Main rzeczy
(setq make-backup-files nil)
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode)
(setq auto-save-default nil)
(setq auto-save-list-file-prefix nil) ;; nawet nie zapisuj listy auto-save
(setq visible-bell t)
(setq ring-bell-function 'ignore)

(setq org-confirm-babel-evaluate nil)
 

; czcionki
(set-face-attribute 'default nil :family "DejaVu Sans Mono" :height 140)

;; C-a goes between char 0 and first char in line
(defun smart-move-beginning-of-line ()
  "Przełącz między początkiem linii a początkiem tekstu (z pominięciem spacji)."
  (interactive)
  (let ((point-was (point)))
    (back-to-indentation)
    (when (= point-was (point))
      (move-beginning-of-line 1))))
(global-set-key (kbd "C-a") #'smart-move-beginning-of-line)


;; zrobienie tego co robi 'o' i 'O' w vimie
(defun open-line-below ()
  "Wstaw nową linię poniżej i przejdź do niej w insert (jak 'o' w Vimie)."
  (interactive)
  (end-of-line)
  (newline-and-indent))

(defun open-line-above ()
  "Wstaw nową linię powyżej i przejdź do niej w insert (jak 'O' w Vimie)."
  (interactive)
  (beginning-of-line)
  (newline-and-indent)
  (forward-line -1)
  (indent-according-to-mode))

(global-set-key (kbd "C-o") 'open-line-below)
(global-set-key (kbd "C-S-o") 'open-line-above)

(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")))

(require 'package)


;; Vertico: pionowe menu podpowiedzi
(use-package vertico
  :ensure t
  :init
  (vertico-mode))


;; Marginalia: opisy przy wynikach (np. typ pliku, tryb bufora)
(use-package marginalia
  :ensure t
  :init (marginalia-mode))


;; Płynne scrollowanie
(setq scroll-margin 0
      scroll-conservatively 100
      scroll-preserve-screen-position 50
      auto-window-vscroll nil)

(use-package good-scroll
  :ensure t
  :config
  (good-scroll-mode 1))


; org ładny
(require 'org)
(require 'org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))



;;;;; BASH ;;;;;;
;; running bash on current line (with output in status line)
(defun run-line-in-bash ()
  "Run current line in bash."
  (interactive)
  (let ((line (thing-at-point 'line t)))
    (shell-command line)))


;; running bash on region (with output in new window)
(defun run-region-bash-compilation ()
  "Run selected region as bash script and show output in a compilation buffer."
  (interactive)
  (unless (use-region-p)
    (error "No region selected"))
  (let* ((code (buffer-substring-no-properties (region-beginning) (region-end)))
         (temp-file (make-temp-file "emacs-bash-" nil ".sh")))
    ;; Zapisz zaznaczony kod do tymczasowego pliku
    (with-temp-file temp-file
      (insert "#!/usr/bin/env bash\n")
      (insert code))

    ;; Nadaj prawa wykonywalne
    (set-file-modes temp-file #o755)

    ;; Uruchom w compilation-mode
    (compile temp-file)))

(global-set-key (kbd "C-c l") 'run-line-in-bash)
(global-set-key (kbd "C-c w") 'run-region-bash-compilation)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((shell . t)))
