#! /bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$CURRENT_DIR/../utils.sh"

if [[ "${INSTALL_LISP_SOURCED-}" != "true" ]]; then
    INSTALL_LISP_SOURCED=true

    install_lisp() {
        print_status "Setting up lisp environment..."
        curl -o /tmp/ql.lisp http://beta.quicklisp.org/quicklisp.lisp
        sbcl --no-sysinit --no-userinit --load /tmp/ql.lisp \
               --eval '(quicklisp-quickstart:install :path "~/.quicklisp")' \
               --eval '(ql:add-to-init-file)' \
               --quit
        print_success "Common Lisp toolchain installation/update complete!"
        return 0
    }
fi

