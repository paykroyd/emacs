;;; disp-table.el --- functions for dealing with char tables.

;; Author: Howard Gayle
;; Maintainer: FSF
;; Last-Modified: 16 Mar 1992

;; Copyright (C) 1987 Free Software Foundation, Inc.

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

;;; Code:

(defun rope-to-vector (rope)
  (let* ((len (/ (length rope) 2))
	 (vector (make-vector len nil))
	 (i 0))
    (while (< i len)
      (aset vector i (rope-elt rope i))
      (setq i (1+ i)))))

(defun describe-display-table (DT)
  "Describe the display table DT in a help buffer."
  (with-output-to-temp-buffer "*Help*"
    (princ "\nTruncation glyph: ")
    (prin1 (aref dt 256))
    (princ "\nWrap glyph: ")
    (prin1 (aref dt 257))
    (princ "\nEscape glyph: ")
    (prin1 (aref dt 258))
    (princ "\nCtrl glyph: ")
    (prin1 (aref dt 259))
    (princ "\nSelective display rope: ")
    (prin1 (rope-to-vector (aref dt 260)))
    (princ "\nCharacter display ropes:\n")
    (let ((vector (make-vector 256 nil))
	  (i 0))
      (while (< i 256)
	(aset vector i
	      (if (stringp (aref dt i))
		  (rope-to-vector (aref dt i))
		(aref dt i)))
	(setq i (1+ i)))
      (describe-vector vector))
    (print-help-return-message)))

(defun describe-current-display-table ()
   "Describe the display table in use in the selected window and buffer."
   (interactive)
   (describe-display-table
    (or (window-display-table (selected-window))
	buffer-display-table
	standard-display-table)))

(defun make-display-table ()
  (make-vector 261 nil))

(defun standard-display-8bit (l h)
  "Display characters in the range L to H literally."
  (while (<= l h)
    (if (and (>= l ?\ ) (< l 127))
	(if standard-display-table (aset standard-display-table l nil))
      (or standard-display-table
	  (setq standard-display-table (make-vector 261 nil)))
      (aset standard-display-table l l))
    (setq l (1+ l))))

(defun standard-display-ascii (c s)
  "Display character C using string S."
  (or standard-display-table
      (setq standard-display-table (make-vector 261 nil)))
  (aset standard-display-table c (apply 'make-rope (append s nil))))

(defun standard-display-g1 (c sc)
  "Display character C as character SC in the g1 character set."
  (or standard-display-table
      (setq standard-display-table (make-vector 261 nil)))
  (aset standard-display-table c
	(make-rope (create-glyph (concat "\016" (char-to-string sc) "\017")))))

(defun standard-display-graphic (c gc)
  "Display character C as character GC in graphics character set."
  (or standard-display-table
      (setq standard-display-table (make-vector 261 nil)))
  (aset standard-display-table c
	(make-rope (create-glyph (concat "\e(0" (char-to-string gc) "\e(B")))))

(defun standard-display-underline (c uc)
  "Display character C as character UC plus underlining."
  (or standard-display-table
      (setq standard-display-table (make-vector 261 nil)))
  (aset standard-display-table c
	(make-rope (create-glyph (concat "\e[4m" (char-to-string uc) "\e[m")))))

;; Allocate a glyph code to display by sending STRING to the terminal.
(defun create-glyph (string)
  (if (= (length glyph-table) 65536)
      (error "No free glyph codes remain"))
  (setq glyph-table (vconcat glyph-table (list string)))
  (1- (length glyph-table)))

(provide 'disp-table)

;;; disp-table.el ends here
