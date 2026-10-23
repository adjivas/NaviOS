{
  den.aspects.firefox-bookmarks-user = {bookmarks ? []}: {
    user,
    policy,
    den,
    ...
  }: {
    includes = policy.optional [
      den.aspects."firefox-bookmarks-user@${user.userName}"
    ];

    homeManager.firefox.bookmarks = bookmarks;
  };
}
