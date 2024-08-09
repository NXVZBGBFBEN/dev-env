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
    emerge app-portage/gentoolkit && \
    emerge app-portage/flaggie

RUN emerge dev-vcs/git && \
    eselect repository enable guru beatussum-overlay && \
    emerge --sync guru beatussum-overlay && \
    flaggie app-admin/chezmoi::guru +kw::~amd64 && emerge app-admin/chezmoi::guru && \
    flaggie app-editors/vim +use::python && emerge app-editors/vim && \
    flaggie dev-util/rustup +kw::~amd64 && emerge dev-util/rustup && \
    flaggie dev-util/shellspec::beatussum-overlay +kw::~amd64 && emerge dev-util/shellspec::beatussum-overlay && \
    emerge --depclean && eclean --deep distfiles

RUN rc-update add sshd default

WORKDIR /home/nxvzbgbfben
USER nxvzbgbfben
SHELL ["/bin/zsh", "-c"]

RUN chezmoi init --apply NXVZBGBFBEN && \
    source .zshenv && \
    rustup-init-gentoo --symlink && \
    { curl -fsSL https://get.pnpm.io/install.sh | sh - } && pnpm env use --global lts && \
    curl https://wasmtime.dev/install.sh -sSf | bash && rm .zshrc

RUN --mount=type=secret,id=ssh_docker,uid=1000,required \
    mkdir -m 700 -p /home/nxvzbgbfben/.ssh && cat /run/secrets/ssh_docker >> /home/nxvzbgbfben/.ssh/authorized_keys

USER root
EXPOSE 22
CMD ["/sbin/init"]
