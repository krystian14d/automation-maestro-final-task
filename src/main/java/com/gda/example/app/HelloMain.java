package com.gda.example.app;

/**
 * Hello World Example.
 */
public class HelloMain {

    public static String defaultPort = "8080";
    public static String sampleApiUrl = "https://api.example.com/data";
    public static String sampleApiKey = "8dyfuiRyq=vVc3RRr_edRk-fK__JItpZ";

    public static void main(String[] args) {

        int port = Integer.parseInt(System.getProperty("port", defaultPort));
        MyServer httpServer = new MyServer();
        httpServer.Start(port);
        ApiConnection apiConnection = new ApiConnection(sampleApiUrl, sampleApiKey);
        apiConnection.sendGetRequest();
    }

}
