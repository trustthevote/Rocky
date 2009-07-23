import com.lowagie.text.DocumentException;
import com.lowagie.text.pdf.AcroFields;
import com.lowagie.text.pdf.PdfReader;
import com.lowagie.text.pdf.PdfStamper;
import com.lowagie.text.pdf.XfdfReader;

import java.io.FileOutputStream;
import java.io.IOException;

public class PdfMerge {
    public static void main(String[] args) throws IOException, DocumentException {

        // read template
        PdfReader pdfreader = new PdfReader(args[0]);

        // read registrant data
        XfdfReader xfdfReader = new XfdfReader(args[1]);

        // prepare data transfer
        PdfStamper stamp = new PdfStamper(pdfreader, new FileOutputStream(args[2]));

        // pour registrant data into template
        AcroFields form = stamp.getAcroFields();
        form.setFields(xfdfReader);

        // write flattened destination pdf
        stamp.setFormFlattening(true);
        stamp.close();

    }
}
