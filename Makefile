NAME=libaio
SPECFILE=$(NAME).spec
VERSION=$(shell awk '/Version:/ { print $$2 }' $(SPECFILE))
RELEASE=$(shell awk '/Release:/ { print $$2 }' $(SPECFILE))
CVSTAG = $(NAME)_$(subst .,-,$(VERSION))_$(subst .,-,$(RELEASE))
RPM=rpm

default: all

all:
	@$(MAKE) -C src

install:
	@$(MAKE) -C src install

clean:
	@$(MAKE) -C src clean

tag-archive:
	@cvs -Q tag -F $(CVSTAG)

create-archive: tag-archive
	@rm -rf /tmp/$(NAME)
	@cd /tmp; cvs -Q -d $(CVSROOT) export -r$(CVSTAG) $(NAME) || echo GRRRrrrrr -- ignore [export aborted]
	@mv /tmp/$(NAME) /tmp/$(NAME)-$(VERSION)
	@cd /tmp; tar czSpf $(NAME)-$(VERSION).tar.gz $(NAME)-$(VERSION)
	@rm -rf /tmp/$(NAME)-$(VERSION)
	@cp /tmp/$(NAME)-$(VERSION).tar.gz .
	@rm -f /tmp/$(NAME)-$(VERSION).tar.gz 
	@echo " "
	@echo "The final archive is ./$(NAME)-$(VERSION).tar.gz."

archive: clean tag-archive create-archive

srpm:
	$(RPM) --define "_sourcedir `pwd`" --define "_srcrpmdir `pwd`" --nodeps -bs $(SPECFILE)
