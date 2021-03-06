(ert-deftest elpy-rpc--open-should-fail-with-bad-backend-value ()
  (elpy-testcase ()
    (let ((elpy-rpc-backend 'jedi))
      (should-error (elpy-rpc--open "test-project" "test-python")))))

(ert-deftest elpy-rpc--open-should-set-local-variables ()
  (elpy-testcase ()
    (mletf* ((start-process (name buffer command &rest args) 'test-process)
             (elpy-rpc-backend "test-backend")
             (requested-backend nil)
             (requested-library-root nil)
             (elpy-rpc-init (backend library-root success)
                            (setq requested-backend backend
                                  requested-library-root library-root)
                            (funcall success '((backend . "test-backend"))))
             (exit-flag-disabled-for nil)
             (sentinel nil)
             (filter nil)
             (set-process-query-on-exit-flag
              (proc flag)
              (when (not flag)
                (setq exit-flag-disabled-for proc)))
             (set-process-sentinel
              (proc fun)
              (when (eq proc 'test-process)
                (setq sentinel fun)))
             (set-process-filter
              (proc fun)
              (when (eq proc 'test-process)
                (setq filter fun))))
      (with-current-buffer (elpy-rpc--open "/tmp" "python")
        (should elpy-rpc--buffer-p)
        (should (equal requested-backend "test-backend"))
        (should (equal requested-library-root "/tmp"))
        (should (equal elpy-rpc--buffer (current-buffer)))
        (should (equal elpy-rpc--backend-library-root "/tmp"))
        (should (equal elpy-rpc--backend-python-command "python"))
        (should (equal default-directory "/"))
        (should (equal exit-flag-disabled-for 'test-process))
        (should (equal sentinel 'elpy-rpc--sentinel))
        (should (equal filter 'elpy-rpc--filter))))))

(ert-deftest elpy-rpc--open-should-change-pythonpath ()
  (elpy-testcase ()
    (mletf* ((elpy-rpc--environment () "test-environment")
             (environment nil)
             (start-process (name buffer command &rest args)
                            (setq environment process-environment))
             (elpy-rpc-init (&rest ignored) nil)
             (set-process-query-on-exit-flag (proc flag) nil)
             (set-process-sentinel (proc fun) nil)
             (set-process-filter (proc fun) nil))

      (elpy-rpc--open "/tmp" "python")

      (should (equal environment "test-environment")))))
