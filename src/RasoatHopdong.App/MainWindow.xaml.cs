using System;
using System.IO;
using System.Windows;
using Microsoft.Web.WebView2.Core;

namespace RasoatHopdong.App;

public partial class MainWindow : Window
{
    public MainWindow()
    {
        InitializeComponent();
        Loaded += MainWindowLoaded;
    }

    private async void MainWindowLoaded(object sender, RoutedEventArgs e)
    {
        await LoadLocalInterfaceAsync();
    }

    private async System.Threading.Tasks.Task LoadLocalInterfaceAsync()
    {
        var indexPath = Path.Combine(AppContext.BaseDirectory, "Web", "index.html");

        if (!File.Exists(indexPath))
        {
            ShowWebViewFallback("Không tìm thấy file Web/index.html trong thư mục chạy ứng dụng.");
            return;
        }

        try
        {
            await LocalWebView.EnsureCoreWebView2Async();
            LocalWebView.CoreWebView2.NavigationStarting += BlockExternalNavigation;
            LocalWebView.Source = new Uri(indexPath);
        }
        catch (Exception)
        {
            ShowWebViewFallback("Không thể khởi tạo WebView2 trong môi trường hiện tại.");
        }
    }

    private static void BlockExternalNavigation(object? sender, CoreWebView2NavigationStartingEventArgs e)
    {
        if (!Uri.TryCreate(e.Uri, UriKind.Absolute, out var uri))
        {
            return;
        }

        if (uri.Scheme == Uri.UriSchemeHttp || uri.Scheme == Uri.UriSchemeHttps)
        {
            e.Cancel = true;
        }
    }

    private void ShowWebViewFallback(string message)
    {
        LocalWebView.Visibility = Visibility.Collapsed;
        WebViewFallbackText.Text = message;
        WebViewFallback.Visibility = Visibility.Visible;
    }
}
