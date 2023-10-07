# -*- mode: make; -*-

# Common Lisp Creche

# create a new common lisp project in my local setup

# To create a new library or utility project:
# $ make all system_type=tools abbrev_name=wat-tool

# To create a new puzzle or game project:
# $ make all system_type=games abbrev_name=wat-game

# expands simple templates

niamod_name := 
author_name := 
author_email := 
source_home := ${HOME}/src
system_path := "$$\\{XDG_DATA_HOME\\}\\/common-lisp\\/source"

ifndef abbrev_name
$(error abbrev_name is undefined)
endif

ifndef niamod_name
$(error niamod_name is undefined)
endif

ifndef author_name
$(error author_name is undefined)
endif

ifndef author_email
$(error author_email is undefined)
endif

ifndef source_home
$(error source_home is undefined)
endif

ifndef system_path
$(error system_path is undefined)
endif

abbrev_name := ${abbrev_name}
system_type := ${system_type}
system_name := $(shell echo $(niamod_name) $(system_type) $(abbrev_name) | tr " " ".")


# TODO: see about a way to make package-user optional
system_filename := ${system_name}.asd

package_main_basename := ${abbrev_name}
package_main_filename := ${package_main_basename}.lisp
package_main_fullname := ${system_name}
package_main_nickname := ${abbrev_name}
package_main_symbol := $(shell echo $(package_main_fullname) | tr "[:lower:]" "[:upper:]")

package_test_basename := $(abbrev_name)-test
package_test_filename := $(package_test_basename).lisp
package_test_fullname := $(system_name)-test
package_test_nickname := $(abbrev_name)-test
package_test_symbol := $(shell echo $(package_test_fullname) | tr "[:lower:]" "[:upper:]")

package_user_basename := $(abbrev_name)-user
package_user_filename := $(package_user_basename).lisp
package_user_fullname := $(system_name)-user
package_user_nickname := $(abbrev_name)-user
package_user_symbol := $(shell echo $(package_user_fullname) | tr "[:lower:]" "[:upper:]")

system_files := $(system_filename) \
	$(package_main_filename) \
	$(package_test_filename) \
	$(package_user_filename)

copyright_year := $(shell date -jn "+%Y")
setup_date := $(shell date -jn "+%F")
setup_weekday := $(shell date -jn "+%a")

builddir := $(system_name)

installdir := $(shell echo $(source_home) $(niamod_name) $(system_type) $(abbrev_name) | tr " " "/")

.PHONY : builddir readme makefile system package package-test package-user

default :
	@echo "targets: package all install clean"

builddir :
	mkdir -p $(builddir)

readme : builddir
	sed \
		-e "s/{{abbrev_name}}/$(abbrev_name)/" \
		-e "s/{{system_name}}/$(system_name)/" \
		-e "s/{{system_path}}/$(system_path)/" \
		-e "s/{{setup_date}}/$(setup_date)/" \
		-e "s/{{setup_weekday}}/$(setup_weekday)/" \
		-e "s/{{author_name}}/$(author_name)/" \
		-e "s/{{author_email}}/$(author_email)/" \
		README.org.template \
		> $(builddir)/README.org

makefile : builddir
	sed \
		-e "s/{{system_name}}/$(system_name)/" \
		-e "s/{{system_path}}/$(system_path)/" \
		-e "s/{{system_files}}/$(system_files)/" \
		Makefile.template \
		> $(builddir)/Makefile

system : builddir
	sed \
		-e "s/{{package_main_basename}}/$(package_main_basename)/" \
		-e "s/{{package_user_basename}}/$(package_user_basename)/" \
		-e "s/{{package_test_basename}}/$(package_test_basename)/" \
		-e "s/{{package_test_fullname}}/$(package_test_fullname)/" \
		-e "s/{{system_name}}/$(system_name)/" \
		-e "s/{{author_name}}/$(author_name)/" \
		-e "s/{{author_email}}/$(author_email)/" \
		-e "s/{{copyright_year}}/$(copyright_year)/" \
		system.asd.template \
		> $(builddir)/$(system_filename)

package-main : builddir
	sed \
		-e "s/{{package_main_fullname}}/$(package_main_fullname)/" \
		-e "s/{{package_main_nickname}}/$(package_main_nickname)/" \
		-e "s/{{package_main_symbol}}/$(package_main_symbol)/" \
		package-main.lisp.template \
		> $(builddir)/$(package_main_filename)

package-test : builddir
	sed \
		-e "s/{{package_test_fullname}}/$(package_test_fullname)/" \
		-e "s/{{package_test_nickname}}/$(package_test_nickname)/" \
		-e "s/{{package_test_symbol}}/$(package_test_symbol)/" \
		package-test.lisp.template \
		> $(builddir)/$(package_test_filename)

package-user : builddir
	sed \
		-e "s/{{package_user_fullname}}/$(package_user_fullname)/" \
		-e "s/{{package_user_nickname}}/$(package_user_nickname)/" \
		-e "s/{{package_main_nickname}}/$(package_main_nickname)/" \
		-e "s/{{package_user_symbol}}/$(package_user_symbol)/" \
		package-user.lisp.template \
		> $(builddir)/$(package_user_filename)

all : readme makefile system package-main package-test package-user

installdirs :
	mkdir -p $(installdir)

install : installdirs
	install $(builddir)/* $(installdir)

# TODO maybe
# git :
# 	git init --initial-branch=main $(installdir)
#       cp scm-excludes #(installdir)/.gitignore

clean :
	rm -rf $(builddir)
