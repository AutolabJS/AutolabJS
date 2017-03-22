package createUsers;


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

public class createUsers {
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
            Scanner scanner = new Scanner(new File("userList"));
            while (scanner.hasNextLine()) {
                String id = scanner.nextLine();
                if (id.length() < 4) continue;
                System.out.println(id);
                String email = "f" + id.substring(0, 4) + "@goa.bits-pilani.co.in";
                try {
                    GitlabUser gitlabUser = g2.createUser(email, id, id, id, "", "", "", "", Integer.valueOf(0), "", "", "", Boolean.valueOf(false), Boolean.valueOf(false), Boolean.valueOf(true));
                    continue;
                }
                catch (Exception e) {
                    e.printStackTrace();
                }
            }
            System.out.println("Users created Successfully...");
            scanner.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
}
