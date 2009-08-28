package com.pivotallabs.rocky;

import com.lowagie.text.DocumentException;

import javax.servlet.http.*;
import java.io.PrintWriter;
import java.io.IOException;

public class PdfServlet extends HttpServlet {

  public void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
    try {
      PdfMerge.process(request.getParameter("nvraTemplatePath"), request.getParameter("tmpPath"), request.getParameter("pdfFilePath"));
    } catch (DocumentException e) {
      e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
      response.setStatus(500);
    }
    response.setStatus(200);
  }


  public void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
    response.setContentType("text/html");
    PrintWriter out = response.getWriter();
    out.println("<h1>Ready to Merge PDFs.</h1>");
    response.setStatus(200);
  }
}
