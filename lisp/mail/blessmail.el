;;; blessmail.el --- Decide whether movemail needs special privileges.

;;; Copyright (C) 1994 Free Software Foundation, Inc.

;; Maintainer: FSF
;; Keywords: internal

;; This file is part of GNU Emacs.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:

;; This is loaded into a bare Emacs to create the blessmail script,
;; which (on systems that need it) is used during installation
;; to give appropriate permissions to movemail.
;;
;; It has to be done from lisp in order to be sure of getting the
;; correct value of rmail-spool-directory.

;;; Code:

(message "Using load-path %s" load-path)
(load "paths.el")
(load "site-init" t)

(let ((attr (file-attributes (file-truename rmail-spool-directory)))
      modes)
  (or (eq t (car attr))
      (signal 'error
	      (list (format "%s is not a directory" rmail-spool-directory))))
  (setq modes (nth 8 attr))
  (insert "#!/bin/sh\n")
  (cond
   ((= ?w (aref modes 8))
    (insert "exit 0"))
   ((= ?w (aref modes 5))
    (insert "chgrp " (number-to-string (nth 3 attr))
	    " $* && chmod g+s $*\n"))
   ((= ?w (aref modes 2))
    (insert "chown " (number-to-string (nth 2 attr))
	    " $* && chmod u+s $*\n"))
   (t
    (insert "chown root $* && chmod u+s $*\n"))))
(write-region (point-min) (point-max) "blessmail")
(kill-emacs)

;;; blessmail.el ends here
