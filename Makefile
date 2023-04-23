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
symbol_name := $(shell echo $(system_name) | tr "[:lower:]" "[:upper:]")

# TODO: see about a way to make package-user optional
package_basename := $(abbrev_name)
package_test_basename := $(abbrev_name)-test
package_user_basename := $(abbrev_name)-user
system_files := $(system_name).asd \
	$(package_basename).lisp \
	$(package_test_basename).lisp \
	$(package_user_basename).lisp

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
		-e "s/{{system_name}}/$(system_name)/" \
		-e "s/{{author_name}}/$(author_name)/" \
		-e "s/{{author_email}}/$(author_email)/" \
		-e "s/{{copyright_year}}/$(copyright_year)/" \
		-e "s/{{package_test_basename}}/$(abbrev_name)-test/" \
		-e "s/{{package_user_basename}}/$(abbrev_name)-user/" \
		system.asd.template \
		> $(builddir)/$(system_name).asd

package : builddir
	sed \
		-e "s/{{package_name}}/$(system_name)/" \
		-e "s/{{package_nickname}}/$(abbrev_name)/" \
		-e "s/{{package_symbol}}/$(symbol_name)/" \
		package.lisp.template \
		> $(builddir)/$(abbrev_name).lisp

package-test : builddir
	sed \
		-e "s/{{package_name}}/$(system_name)-test/" \
		-e "s/{{package_nickname}}/$(abbrev_name)-test/" \
		-e "s/{{package_symbol}}/$(symbol_name)-TEST/" \
		package-test.lisp.template \
		> $(builddir)/$(abbrev_name)-test.lisp

package-user : builddir
	sed \
		-e "s/{{package_name}}/$(system_name)-user/" \
		-e "s/{{package_nickname}}/${abbrev_name}-user/" \
		-e "s/{{import_from_name}}/$(abbrev_name)/" \
		-e "s/{{package_symbol}}/$(symbol_name)-USER/" \
		package-user.lisp.template \
		> $(builddir)/$(abbrev_name)-user.lisp

all : readme makefile system package package-test package-user

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
