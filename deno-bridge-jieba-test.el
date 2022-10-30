(ert-deftest deno-bridge-jieba-forward-word-test01
    ()
  (with-temp-buffer
    (insert "可惜不是你，陪我到最后")
    (beginning-of-line)
    (deno-bridge-jieba-forward-word)
    (sleep-for 1) ;; deno bridge is asynchronous
    (should (string= (string (char-before)) "惜"))
    ))

(ert-deftest deno-bridge-jieba-forward-word-test02
    ()
  (with-temp-buffer
    (insert "Hello World")
    (beginning-of-line)
    (deno-bridge-jieba-forward-word)
    (sleep-for 1) ;; deno bridge is asynchronous
    (should (string= (string (char-before)) "o"))
    ))

(ert-deftest deno-bridge-jieba-forward-word-test02
    ()
  (with-temp-buffer
    (insert "  Hello")
    (beginning-of-line)
    (deno-bridge-jieba-forward-word)
    (sleep-for 1) ;; deno bridge is asynchronous
    (should (string= (string (char-after)) "H"))
    ))
