package com.pivotallabs.rocky;

import org.mortbay.jetty.servlet.Context;
import org.mortbay.jetty.servlet.ServletHolder;

public class PdfServer {
  public static void main(String[] args) throws Exception {
    org.mortbay.jetty.Server server = new org.mortbay.jetty.Server(8080);
    Context writerContext = new Context(server, "/pdfmerge", Context.SESSIONS);
    writerContext.addServlet(new ServletHolder(new PdfServlet()), "/*");

    server.start();
    server.join();
  }
}
