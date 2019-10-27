##
FROM	alpine:edge
SHELL	["/bin/ash", "-xeuo", "pipefail", "-c"]

RUN	addgroup -S rtlsdr; \
	adduser -H -D -S -s /dev/null -g rtlsdr rtlsdr

RUN	apk update; \
        apk upgrade; \
        apk --no-cache --update --upgrade add ca-certificates build-base cmake git libusb-dev libusb-compat-dev;

ARG	RTLSDR_VCS="git://git.osmocom.org/rtl-sdr"
RUN	git clone --single-branch --progress "${RTLSDR_VCS}" /usr/src/rtl-sdr; \
	mkdir -vp /usr/src/rtl-sdr/build; \
	cd /usr/src/rtl-sdr/build; \
	cmake \
		-DENABLE_ZEROCOPY=ON \
		-DINSTALL_UDEV_RULES=ON \
		-DDETACH_KERNEL_DRIVER=ON \
		..; \
	make -j$(nproc) install

##
FROM	alpine:edge
SHELL	["/bin/ash", "-xeuo", "pipefail", "-c"]

COPY    --from=0        /etc/passwd /etc/group  /etc/

RUN     apk update; \
        apk upgrade; \
        apk --no-cache --update --upgrade add libusb-dev

COPY    --from=0        /usr/local              /usr/local

USER	rtlsdr

EXPOSE	1234/tcp

ENTRYPOINT ["/usr/local/bin/rtl_tcp"]
CMD	["-a", "::"]
