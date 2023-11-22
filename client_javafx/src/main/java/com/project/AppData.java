package com.project;

import java.net.URI;
import java.net.URISyntaxException;

import org.java_websocket.client.WebSocketClient;
import org.java_websocket.drafts.Draft;
import org.java_websocket.drafts.Draft_6455;
import org.java_websocket.handshake.ServerHandshake;
import org.json.JSONObject;

import javafx.application.Platform;

public class AppData {
    private static final AppData INSTANCE = new AppData();
    private WebSocketClient wSClient;
    private String ip = "localhost";
    private String port = "8888";
    private ConnectionStatus connectionStatus = ConnectionStatus.DISCONNECTED;
    private String name = "Default";
    
    public enum ConnectionStatus {
        DISCONNECTED, DISCONNECTING, CONNECTING, CONNECTED
    }
    
    private AppData() {
    }

    public static AppData getInstance() {
        return INSTANCE;
    }

    public void connectToServer() {
        String uri = "ws://" + ip + ":" + port;

        try {
            wSClient = new WebSocketClient(new URI(uri), (Draft) new Draft_6455()) {
                @Override
                public void onOpen(ServerHandshake handshake) {
                    connectionStatus = ConnectionStatus.CONNECTING; 
                    System.out.println("Connected to: " + getURI());
                    Platform.runLater(() -> {
                        UtilsViews.setViewAnimating("ViewConnecting");
                    });
                    wSClient.send("{ \"type\": \"name\", \"value\": \"" + name + "\"}");
                }

                @Override
                public void onMessage(String message) {
                    
                    JSONObject data = new JSONObject(message);

                    if (connectionStatus != ConnectionStatus.CONNECTED) {
                        connectionStatus = ConnectionStatus.CONNECTED;
                    }

                    String type = data.getString("type");
                    switch (type) {
                        case "id":
                                try {
                                    Thread.sleep(500);
                                } catch (InterruptedException e) {
                                    e.printStackTrace();
                                }
                            Platform.runLater(() -> {
                                UtilsViews.setViewAnimating("View0");
                            });
                            
                            System.out.println("O_O");
                            break;
                        default:
                            System.out.println("Message: " + message);
                            break;
                    }
                    if (connectionStatus == ConnectionStatus.CONNECTED) {  }
                }

                @Override
                public void onClose(int code, String reason, boolean remote) {
                    connectionStatus = ConnectionStatus.DISCONNECTED;
                    System.out.println("Disconnected from: " + getURI());
                    Platform.runLater(() -> {
                        UtilsViews.setViewAnimating("ViewLogin");
                    });
                }

                @Override
                public void onError(Exception ex) {
                    System.out.println("Error: " + ex.getMessage());
                }
            };

            wSClient.connect();

        } catch (URISyntaxException e) {
            e.printStackTrace();
            System.out.println("Error: " + uri + " no es una dirección URI de WebSocket válida");
        }

    }

    public void disconnectFromServer() {
        if (wSClient != null && wSClient.isOpen()) {
            connectionStatus = ConnectionStatus.DISCONNECTING;
            wSClient.close();
        }
    }

    public String getIp() {
        return ip;
    }

    public String setIp (String ip) {
        return this.ip = ip;
    }

    public String getPort() {
        return port;
    }

    public String setPort (String port) {
        return this.port = port;
    }

    public String getName() {
        return name;
    }

    public String setName(String name) {
        return this.name = name;
    }
}
