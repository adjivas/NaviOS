{
  den.aspects.firefox-pinned-user = {pinned ? []}: {
    user,
    policy,
    den,
    ...
  }: {
    includes = policy.optional [
      den.aspects."firefox-pinned-user@${user.userName}"
    ];

    homeManager.firefox.pinned = pinned;
  };
}
