##
FROM	alpine:edge

SHELL	["/bin/ash", "-xeuo", "pipefail", "-c"]

ARG	RTLSDR_VCS="git://git.osmocom.org/rtl-sdr"

RUN	apk update; \
	apk upgrade; \
	apk --no-cache --update --upgrade add ca-certificates bash build-base cmake git libusb-dev libusb-compat-dev; \
	git clone --single-branch --progress "${RTLSDR_VCS}" /usr/src/rtl-sdr; \
	mkdir -vp /usr/src/rtl-sdr/build; \
	cd /usr/src/rtl-sdr/build; \
	cmake \
		-DENABLE_ZEROCOPY=ON \
		-DINSTALL_UDEV_RULES=ON \
		-DDETACH_KERNEL_DRIVER=ON \
		..; \
	make install

##
FROM	alpine:edge
SHELL	["/bin/ash", "-xeuo", "pipefail", "-c"]

RUN     apk update; \
        apk upgrade; \
        apk --no-cache --update --upgrade add libusb-dev

# copy rtlsdr
COPY	--from=0	/usr/local	/usr/local

EXPOSE	1234/tcp

ENTRYPOINT ["/usr/local/bin/rtl_tcp"]
CMD	["-a", "0.0.0.0"]
