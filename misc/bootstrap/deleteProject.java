package deleteProject;


import java.io.File;
import java.io.PrintStream;
import java.security.SecureRandom;
import java.util.Scanner;
import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.KeyManager;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import javax.net.ssl.SSLSession;
import org.gitlab.api.GitlabAPI;
import org.gitlab.api.models.GitlabSession;
import org.gitlab.api.models.GitlabUser;
import org.gitlab.api.models.GitlabProject;
import java.io.Serializable;


public class deleteProject {
    public static void main(String[] args) {
        try {
           TrustManager[] trustAllCerts = new TrustManager[]{
    new X509TrustManager() {
        public java.security.cert.X509Certificate[] getAcceptedIssuers() {
            return null;
        }
        public void checkClientTrusted(
            java.security.cert.X509Certificate[] certs, String authType) {
        }
        public void checkServerTrusted(
            java.security.cert.X509Certificate[] certs, String authType) {
        }
    }
};
             SSLContext sc = SSLContext.getInstance("SSL");
        sc.init(null, trustAllCerts, new SecureRandom());
        HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory());
        HostnameVerifier allHostsValid = new HostnameVerifier(){

            @Override
            public boolean verify(String hostname, SSLSession session) {
                return true;
            }
        };
            HttpsURLConnection.setDefaultHostnameVerifier((HostnameVerifier)allHostsValid);
            Scanner read_config = new Scanner(new File("gitlab_config"));
            String hostname = read_config.nextLine();
            String root_name = read_config.nextLine();
            String root_pass = read_config.nextLine();
            read_config.close();
            GitlabSession g = GitlabAPI.connect((String)("https://" + hostname), (String)root_name, (String)root_pass);
            System.out.println(g.getPrivateToken());
            GitlabAPI g2 = GitlabAPI.connect((String)("https://" + hostname), (String)g.getPrivateToken());
            for (GitlabProject project : g2.getAllProjects()) {
                if (!project.getName().equals(args[0])) continue;
                System.out.println(project.getName());
                g2.deleteProject((Serializable)project.getId());
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
}
