package resource;

import java.io.IOException;

public class runmathjax {
    public static void main() {

        ProcessBuilder pb = new ProcessBuilder("node", "call-mathjax.js", "simple.mml");
        try {
            Process p = pb.start();
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }
}
