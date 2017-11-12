include vars.mk

# bashscripts += ..
libs += @dvermeir/cbuf
src = vchunk.es7
tst = vchunk-test.es7 assert-test.es7
all: install 

include rules.mk

xdoc: doc
	scp $(mdfiles) dv50:md
