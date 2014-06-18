SUBDIRS = examples
nobase_include_HEADERS = elfio/elf_types.hpp     elfio/elfio_dynamic.hpp    \
                         elfio/elfio.hpp         elfio/elfio_header.hpp     \
                         elfio/elfio_note.hpp    elfio/elfio_relocation.hpp \
                         elfio/elfio_section.hpp elfio/elfio_segment.hpp    \
                         elfio/elfio_strings.hpp elfio/elfio_symbols.hpp    \
                         elfio/elfio_utils.hpp   elfio/elfio_dump.hpp
EXTRA_DIST = doc/site/elfio.pdf
dist-hook:
	mv $(distdir)/doc/site/elfio.pdf $(distdir)/doc
	rm -Rf $(distdir)/doc/site
