{ users, profiles, userProfiles, ... }:

{
  system = with profiles; rec {
    base = [ core basic users.root users.yinfeng ];

    network = (with networking; [ network-manager resolved ]) ++ (with security; [ fail2ban firewall ]);
    multimedia = (with graphical; [ gnome fonts ibus-chinese ]) ++ (with services; [ sound ]);
    development = (with profiles.development; [ shells latex ]) ++ (with services; [ adb gnupg ]);
    multimediaDev = multimedia ++ development ++ (with profiles.development; [ ides ]);
    virtualization = with profiles.virtualization; [ docker libvirt wine ];
    wireless = with services; [ bluetooth ];
    gfw = with networking; [ gfw-proxy ];
    campus = with networking; [ campus-network ];
    game = with graphical.game; [ steam ];
    ciAgent = with services; [ hercules-ci-agent ];

    workstation = base ++ multimediaDev ++ virtualization ++ network ++ wireless ++ (with services; [ openssh printing ]);
    mobileWorkstation = workstation ++ campus ++ [ laptop ];
    desktopWorkstation = workstation ++ ciAgent;
  };
  user = with userProfiles; rec {
    base = [ direnv git git-extra shells ];
    multimedia = [ gnome desktop-applications rime fonts ];
    development = [ userProfiles.development emacs tools ];
    virtualization = [ ];
    multimediaDev = multimedia ++ development ++ [ vscode ];
    synchronize = [ onedrive digital-paper ];

    full = base ++ multimediaDev ++ virtualization ++ synchronize;
  };
}
