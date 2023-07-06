((exports) => {
  // eslint-disable-next-line id-length
  const $ = exports.$;

  $.fn.youtubeModal = function() {
    return $(this).each((_i, element) => {
      const videoId = $(element).data("open-youtube");
      const $modal = $(`#${$(element).data("open")}`);

      $modal.on("open.zf.reveal", () => {
        $modal.css("top", "");

        const $iframe = $(
          "<iframe class=\"youtube-player\" type=\"text/html\" frameborder=\"0\" />"
        ).attr(
          "src",
          `https://www.youtube.com/embed/${videoId}?autoplay=1`
        ).attr(
          "allow",
          "autoplay; fullscreen"
        ).attr(
          "allowfullscreen",
          "true"
        );
        $modal.prepend($iframe);
      }).on("closed.zf.reveal", () => {
        $("iframe.youtube-player", $modal).remove();
      });
    });
  };
})(window);
