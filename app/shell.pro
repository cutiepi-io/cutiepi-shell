TARGET = shell
TEMPLATE = app
QT += qml quick webengine widgets

SOURCES += main.cpp \
        backlight.cpp

HEADERS += backlight.h

contains(DEFINES, USE_ADBLOCK) {
	SOURCES += third_party/ad-block/ad_block_client.cc \
		third_party/ad-block/no_fingerprint_domain.cc \
		third_party/ad-block/filter.cc \
		third_party/ad-block/protocol.cc \
		third_party/ad-block/context_domain.cc \
		third_party/ad-block/cosmetic_filter.cc \
		third_party/bloom-filter-cpp/BloomFilter.cpp \ 
		third_party/hashset-cpp/hash_set.cc \
		third_party/hashset-cpp/hashFn.cc

	HEADERS += third_party/ad-block/ad_block_client.h 
}
