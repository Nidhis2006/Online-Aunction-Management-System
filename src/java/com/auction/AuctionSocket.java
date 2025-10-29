package com.auction;

import jakarta.websocket.OnClose;
import jakarta.websocket.OnError;
import jakarta.websocket.OnMessage;
import jakarta.websocket.OnOpen;
import jakarta.websocket.Session;
import jakarta.websocket.server.PathParam;
import jakarta.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArraySet;

/**
 * WebSocket channel per product: /ws/auction/{productId}
 * Broadcasts JSON messages like:
 * {"type":"state","bidder":"Alice","amount":1234.0,"ended":false}
 */
@ServerEndpoint("/ws/auction/{productId}")
public class AuctionSocket {

    // productId -> sessions watching that product
    private static final ConcurrentHashMap<Integer, CopyOnWriteArraySet<Session>> ROOMS = new ConcurrentHashMap<>();

    @OnOpen
    public void onOpen(Session session, @PathParam("productId") int productId) {
        ROOMS.computeIfAbsent(productId, k -> new CopyOnWriteArraySet<>()).add(session);
        // Push current state on connect
        try {
            String state = AuctionService.buildStatusJson(productId);
            session.getBasicRemote().sendText(state);
        } catch (Exception ignored) {}
    }

    @OnClose
    public void onClose(Session session, @PathParam("productId") int productId) {
        Set<Session> set = ROOMS.get(productId);
        if (set != null) {
            set.remove(session);
            if (set.isEmpty()) ROOMS.remove(productId);
        }
    }

    @OnError
    public void onError(Session session, Throwable t) {
        // Let container log details
    }

    @OnMessage
    public void onMessage(String msg, Session session, @PathParam("productId") int productId) {
        // Optional: handle pings/commands; ignored for now
    }

    /** Broadcast latest computed state to everyone watching this product. */
    public static void broadcastState(int productId) {
        CopyOnWriteArraySet<Session> set = ROOMS.get(productId);
        if (set == null || set.isEmpty()) return;
        String payload;
        try {
            payload = AuctionService.buildStatusJson(productId);
        } catch (Exception e) {
            return;
        }
        for (Session s : set) {
            if (s.isOpen()) {
                try { s.getBasicRemote().sendText(payload); }
                catch (IOException ignored) {}
            }
        }
    }
}
