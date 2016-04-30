defmodule ApiServer.LayoutView do
  use ApiServer.Web, :view

  def ga_key do
    System.get_env("GA_KEY")
  end

  def ga_block do
    case ga_key do
      nil -> ""
      x ->
        """
            <script>(function(i,s,o,g,r,a,m){i["GoogleAnalyticsObject"]=r;i[r]=i[r]||function(){(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();
            a=s.createElement(o),m=s.getElementsByTagName(o)[0];a.async=1;
            a.src=g;m.parentNode.insertBefore(a,m)})(window,document,"script","//www.google-analytics.com/analytics.js","ga");
            ga("create", "#{x}", {"cookieDomain":"auto"});
            ga("send", "pageview");</script>
        """
    end
  end

end
