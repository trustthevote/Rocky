package com.pivotallabs.rocky;

import com.lowagie.text.DocumentException;
import com.lowagie.text.pdf.AcroFields;
import com.lowagie.text.pdf.PdfReader;
import com.lowagie.text.pdf.PdfStamper;
import com.lowagie.text.pdf.XfdfReader;

import java.io.FileOutputStream;
import java.io.IOException;

public class PdfMerge {

  public static void main(String[] args) throws IOException, DocumentException {
    process(args[0], args[1], args[2]);
  }

  public static void process(String nvraTemplatePath, String tmpPath, String pdfFilePath) throws IOException, DocumentException {
    // read template
    PdfReader pdfreader = new PdfReader(nvraTemplatePath);

    // read registrant data
    XfdfReader xfdfReader = new XfdfReader(tmpPath);

    // prepare data transfer
    PdfStamper stamp = new PdfStamper(pdfreader, new FileOutputStream(pdfFilePath));

    // pour registrant data into template
    AcroFields form = stamp.getAcroFields();
    form.setFields(xfdfReader);

    // write flattened destination pdf
    stamp.setFormFlattening(true);
    stamp.close();
  }
}
