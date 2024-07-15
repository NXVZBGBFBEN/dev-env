FROM gentoo/portage:latest AS portage
FROM gentoo/stage3:latest

COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

RUN cd /etc/portage && \
    sed -i \
        -e '/COMMON_FLAGS=/c COMMON_FLAGS="-march=native -O2 -pipe"' \
        -e '$a\\nGENTOO_MIRRORS=https://ftp.jaist.ac.jp/pub/Linux/Gentoo/' \
    make.conf && \
    touch package.env && \
    touch package.license && \
    rmdir package.mask && touch package.mask && \
    touch package.properties && \
    rmdir package.use && touch package.use && \
    rmdir package.accept_keywords && touch package.accept_keywords && \
    touch package.accept_restrict && \
    mkdir repos.conf && \
    cd / && \
    emerge --oneshot app-portage/cpuid2cpuflags && echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use && \
    echo "Asia/Tokyo" > "/etc/timezone" && emerge --config sys-libs/timezone-data && \
    sed -i '/#en_US.UTF-8 UTF-8/c en_US.UTF-8 UTF-8' /etc/locale.gen && locale-gen && eselect locale set en_US.UTF-8 && \
    env-update && source /etc/profile && \
    emerge net-misc/aria2 && \
    sed -i \
        -e '$a\\nFETCHCOMMAND="/usr/bin/aria2c -d \\"\\${DISTDIR}\\" -o \\"\\${FILE}\\" \\"\\${URI}\\""' \
        -e '$a\RESUMECOMMAND="/usr/bin/aria2c -d \\"\\${DISTDIR}\\" -o \\"\\${FILE}\\" \\"\\${URI}\\""' \
    /etc/portage/make.conf && \
    emerge app-shells/zsh && chsh -s /bin/zsh && \
    useradd -m -G wheel nxvzbgbfben -s /bin/zsh && \
    emerge app-admin/sudo && sed -i '/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/c %wheel ALL=(ALL:ALL) NOPASSWD: ALL' /etc/sudoers && \
    emerge app-eselect/eselect-repository && \
    emerge app-portage/gentoolkit

RUN emerge dev-vcs/git && \
    eselect repository enable guru beatussum-overlay && \
    emerge --sync guru beatussum-overlay && \
    echo "app-admin/chezmoi::guru ~amd64" >> /etc/portage/package.accept_keywords && emerge app-admin/chezmoi::guru && \
    emerge app-editors/vim && \
    echo "dev-util/rustup ~amd64" >> /etc/portage/package.accept_keywords && emerge dev-util/rustup && \
    echo "dev-util/shellspec::beatussum-overlay ~amd64" >> /etc/portage/package.accept_keywords && emerge dev-util/shellspec::beatussum-overlay && \
    emerge --depclean && eclean --deep distfiles

WORKDIR /home/nxvzbgbfben
USER nxvzbgbfben
SHELL ["/bin/zsh", "-c"]

RUN chezmoi init --apply NXVZBGBFBEN

RUN rustup-init-gentoo --symlink

USER root
CMD ["/sbin/init"]
