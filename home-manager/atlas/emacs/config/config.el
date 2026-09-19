;; Set up package.el to work with MELPA
;; Enable Evil
(use-package evil
  :ensure t
  :custom
  (evil-undo-system 'undo-redo)
  (evil-want-keybinding nil)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :ensure t
  :config
  (evil-collection-init))

(use-package org-roam
  :ensure t
  :bind  (("M-n l" . org-roam-buffer-toggle)
          ("M-n f" . org-roam-node-find)
          ("M-n g" . org-roam-graph)
          ("M-n i" . org-roam-node-insert)
          ("M-n c" . org-roam-capture)
          ;; Dailies
          ("M-n j" . org-roam-dailies-capture-today))
  :custom
  (org-roam-directory (file-truename "~/Sync/org/roam"))
  :config
  ;; If you're using a vertical completion framework, you might want a more informative completion interface
  (setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  (org-roam-db-autosync-mode)
  ;; If using org-roam-protocol
  (require 'org-roam-protocol))

(use-package elfeed
  :ensure t
  :bind (("C-x w") 'elfeed))
(use-package elfeed-org
  :ensure t
  :custom
  (rmh-elfeed-org-files (list "~/.emacs.d/elfeed.org"))
  :init
  (elfeed-org))
