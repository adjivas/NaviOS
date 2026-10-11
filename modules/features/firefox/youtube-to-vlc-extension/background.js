const pendingTabs = new Set();

function isYouTubeVideo(rawUrl) {
  try {
    const url = new URL(rawUrl);

    return (
      url.protocol === "https:"
      && [
        "youtube.com",
        "www.youtube.com",
        "m.youtube.com",
      ].includes(url.hostname)
      && url.pathname === "/watch"
      && url.searchParams.has("v")
    );
  } catch {
    return false;
  }
}

async function openInVlc(tabId, rawUrl) {
  if (pendingTabs.has(tabId) || !isYouTubeVideo(rawUrl)) {
    return;
  }

  pendingTabs.add(tabId);

  try {
    const response = await browser.runtime.sendNativeMessage(
      "local.youtube_to_vlc",
      {
        command: "play",
        url: rawUrl,
      },
    );

    if (!response.ok) {
      throw new Error(response.error);
    }

    await browser.tabs.remove(tabId);
  } catch (error) {
    console.error("Unable to open YouTube video in VLC:", error);
  } finally {
    pendingTabs.delete(tabId);
  }
}

browser.tabs.onUpdated.addListener((tabId, changeInfo) => {
  if (changeInfo.url) {
    openInVlc(tabId, changeInfo.url);
  }
});
