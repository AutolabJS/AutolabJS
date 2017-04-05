package gitlab_wrapper;


import java.io.File;
import java.io.IOException;
import java.io.PrintStream;
import java.security.KeyManagementException;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Scanner;
import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.KeyManager;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import javax.security.cert.X509Certificate;
import org.gitlab.api.GitlabAPI;
import org.gitlab.api.models.GitlabAccessLevel;
import org.gitlab.api.models.GitlabProject;
import org.gitlab.api.models.GitlabProjectMember;
import org.gitlab.api.models.GitlabSession;
import org.gitlab.api.models.GitlabUser;

public class createLab {
    public static void main(String[] args) throws IOException, NoSuchAlgorithmException, KeyManagementException {
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
        HttpsURLConnection.setDefaultHostnameVerifier(allHostsValid);
        Scanner read_config = new Scanner(new File("gitlab_config"));
        String hostname = read_config.nextLine();
        String root_name = read_config.nextLine();
        String root_pass = read_config.nextLine();
        read_config.close();
        GitlabSession g = GitlabAPI.connect((String)("https://" + hostname), (String)root_name, (String)root_pass);
        System.out.println(g.getPrivateToken());
        GitlabAPI g2 = GitlabAPI.connect((String)("https://" + hostname), (String)g.getPrivateToken());
        if (args.length >= 1) {
            GitlabProject project = g2.createProject(args[0]);
            Scanner scanner = new Scanner(new File("userList"));
            while (scanner.hasNextLine()) {
                String userName = scanner.nextLine();
                try {
                    GitlabUser user = g2.getUserViaSudo(userName);
                    g2.addProjectMember(project, user, GitlabAccessLevel.Guest);
                    continue;
                }
                catch (Exception e) {
                    e.printStackTrace();
                }
            }
            scanner.close();
        } else {
            System.err.println("Enter a project name");
        }
    }

}
