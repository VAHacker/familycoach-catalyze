package gov.va.ptsd.ptsdcoach.compiler;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectOutputStream;
import java.io.Reader;
import java.io.StringReader;
import java.io.StringWriter;
import java.nio.channels.FileChannel;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.RowId;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.Format;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Map;
import java.util.TreeMap;
import java.util.TreeSet;

import org.cyberneko.html.parsers.DOMParser;
import org.jdom.Attribute;
import org.jdom.DataConversionException;
import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.input.SAXBuilder;
import org.jdom.output.XMLOutputter;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.w3c.dom.bootstrap.DOMImplementationRegistry;
import org.w3c.dom.ls.DOMImplementationLS;
import org.w3c.dom.ls.LSOutput;
import org.w3c.dom.ls.LSSerializer;
import org.xml.sax.InputSource;

public class Main {

	static final int TYPE_FLOAT = 1;
	static final int TYPE_STRING = 2;
	static final int TYPE_THEME_REFERENCE = 3;
	static final int TYPE_CONTENT_REFERENCE = 4;
	static final int TYPE_MULTI_CONTENT_REFERENCE = 5;
	static final int TYPE_FILE = 6;
	
	static class FieldDescriptor {
		String columnName;
		int columnIndex;
		int columnType;
		
		public FieldDescriptor(String name, int index, int type) {
			columnName = name;
			columnIndex = index;
			columnType = type;
		}
	}
	
	static TreeMap<String,FieldDescriptor> contentFields = new TreeMap<String, Main.FieldDescriptor>();
	static TreeSet<String> filesToCopy = new TreeSet<String>();
	static TreeSet<String> uniqueIDs = new TreeSet<String>();
	static int elmCount = 0;

	static {
		contentFields.put("name",new FieldDescriptor("name", 5, TYPE_STRING));
		contentFields.put("displayName",new FieldDescriptor("displayName", 6, TYPE_STRING));
		contentFields.put("help",new FieldDescriptor("help", 7, TYPE_CONTENT_REFERENCE));
		contentFields.put("weight",new FieldDescriptor("weight", 8, TYPE_FLOAT));
		contentFields.put("ui",new FieldDescriptor("ui", 9, TYPE_STRING));
		contentFields.put("helpsWithSymptoms",new FieldDescriptor(null, -1, TYPE_MULTI_CONTENT_REFERENCE));
		contentFields.put("icon",new FieldDescriptor("icon", -1, TYPE_FILE));
		contentFields.put("image",new FieldDescriptor("image", -1, TYPE_FILE));
		contentFields.put("bgImage",new FieldDescriptor("bgImage", -1, TYPE_FILE));
		contentFields.put("bgImagePressed",new FieldDescriptor("bgImagePressed", -1, TYPE_FILE));
		contentFields.put("ref",new FieldDescriptor("ref", -1, TYPE_CONTENT_REFERENCE));
		contentFields.put("audio",new FieldDescriptor("audio", -1, TYPE_FILE));
	}
	
	static Connection conn;
	static PreparedStatement insertContent;
	static PreparedStatement insertContentText;
	static PreparedStatement insertContentLink;
	static PreparedStatement queryContentByName;
	
	static class UnresolvedReference {
		long referrer;
		String field;
		String referreeName;
		
		public UnresolvedReference(long referrer, String field, String referreeName) {
			this.referrer = referrer;
			this.field = field;
			this.referreeName = referreeName;
		}
	}
	
	static ArrayList<UnresolvedReference> refsToResolve = new ArrayList<UnresolvedReference>();
	
	static void init(String dbname) {
		try {
			Class.forName("org.sqlite.JDBC");
			conn = DriverManager.getConnection("jdbc:sqlite:"+dbname);
			Statement stat = conn.createStatement();

			stat.executeUpdate("drop table if exists android_metadata;");
			stat.executeUpdate("create table android_metadata (locale TEXT DEFAULT 'en_US');");
			stat.executeUpdate("insert into android_metadata VALUES ('en_US');");

			stat.executeUpdate("drop table if exists contentText;");
			stat.executeUpdate(	"create table contentText (_id INTEGER PRIMARY KEY ASC, body TEXT, attributes BLOB);");

			stat.executeUpdate("drop table if exists content;");
			stat.executeUpdate(	"create table content (_id INTEGER PRIMARY KEY ASC, parent INT, ordering INT, uniqueID TEXT, type TEXT, name TEXT, displayName TEXT, help INT, weight REAL, ui TEXT);");
			stat.executeUpdate(	"create index content_name_idx on content (name);");
			stat.executeUpdate(	"create index content_parent_idx on content (parent);");
			stat.executeUpdate(	"create index content_uniqueID_idx on content (uniqueID);");

			stat.executeUpdate("drop table if exists content_link;");
			stat.executeUpdate(	"create table content_link (_id INTEGER PRIMARY KEY ASC, referrer INT, field TEXT, referree INT);");
			stat.executeUpdate(	"create index content_link_referrer_idx on content_link (referrer,field);");
			stat.executeUpdate(	"create index content_link_referree_idx on content_link (referree);");

			queryContentByName = conn.prepareStatement("select * from content where name=?;");
			insertContent = conn.prepareStatement("insert into content (parent,ordering,uniqueID,type,name,displayName,help,weight,ui) VALUES (?,?,?,?,?,?,?,?,?);");
			insertContentText = conn.prepareStatement("insert into contentText (_id,body,attributes) VALUES (?,?,?);");
			insertContentLink = conn.prepareStatement("insert into content_link (referrer,field,referree) VALUES (?,?,?);");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	static byte[] serialize(Object o) throws IOException {
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		ObjectOutputStream out = new ObjectOutputStream(baos);
		out.writeObject(o);
		out.close();
		return baos.toByteArray();
	}
	
	static public void addTheme(Element elm) {

	}

	static public void addElement(long parent, int order, Map<String,String> defaults, Element elm) throws SQLException, DataConversionException, IOException {
		addContent(parent,order,defaults,elm);
	}

	public static String getHexString(byte[] b) {
		String result = "";
		for (int i=0; i < b.length; i++) {
			result +=
				Integer.toString( ( b[i] & 0xff ) + 0x100, 16).substring( 1 );
		}
		return result;
	}
/*
	static public void addCaption(long parent, int order, Element elm) throws SQLException, DataConversionException, IOException {
		insertCaption.clearParameters();

		insertCaption.setLong(1, parent);
		insertCaption.setInt(2, order);

		String[] s;
		int minutes,seconds;
		
		s = elm.getAttributeValue("start").split(":");
		minutes = Integer.parseInt(s[0],10);
		seconds = Integer.parseInt(s[1],10);
		int startTime = ((minutes * 60) + seconds) * 1000;
		insertCaption.setInt(3, startTime);

		s = elm.getAttributeValue("end").split(":");
		minutes = Integer.parseInt(s[0],10);
		seconds = Integer.parseInt(s[1],10);
		int endTime = ((minutes * 60) + seconds) * 1000;
		insertCaption.setInt(4, endTime);
		
		String text = elm.getText().trim();
		insertCaption.setString(5, text);
		
		System.out.println("caption("+parent+","+order+","+startTime+","+endTime+"):'"+text+"'");
		
		insertCaption.execute();
	}
*/

	static void gatherImages(org.w3c.dom.Element elm) {
		if (elm.getTagName().equalsIgnoreCase("img")) {
			String src = elm.getAttribute("src");
			if (src.startsWith("Content/")) {
				src = src.substring(8);
				filesToCopy.add(src);
			}
 		}
		
		NodeList list = elm.getChildNodes();
		for (int i=0;i<list.getLength();i++) {
			Node node = list.item(i);
			if (node.getNodeType() == Node.ELEMENT_NODE) {
				org.w3c.dom.Element child = (org.w3c.dom.Element)node;
				gatherImages(child);
			}
		}
	}
	
	static String convertHTML(String html) {
		try {
			org.apache.xerces.parsers.DOMParser parser = new DOMParser();
			parser.parse(new InputSource(new StringReader(html)));
			org.w3c.dom.Document doc = parser.getDocument();
			org.w3c.dom.Element root = doc.getDocumentElement();
			gatherImages(root);
/*			
			DOMImplementationRegistry registry = DOMImplementationRegistry.newInstance();    
			DOMImplementationLS impl = (DOMImplementationLS) registry.getDOMImplementation("XML 3.0 LS 3.0");
			LSSerializer serializer = impl.createLSSerializer();
	        LSOutput output = impl.createLSOutput();
	        output.setEncoding("UTF-8");
	        output.setByteStream(System.out);
	        serializer.write(doc, output);
	        System.out.println();
			StringWriter writer = new StringWriter();
			XMLOutputter outputter = new XMLOutputter();
		    try {
		      outputter.output(doc, writer);       
		    } catch (IOException e) {
				e.printStackTrace();
				System.exit(-1);
		    }
		    html = writer.toString();
*/		    
		} catch (Throwable e) {
			e.printStackTrace();
			System.exit(-1);
		}

		return html;
	}
	
	static public void addContent(long parent, int order, Map<String,String> defaults, Element elm) throws SQLException, DataConversionException, IOException {
		TreeMap<String,Object> extras = new TreeMap<String, Object>();
		TreeMap<String,String> childDefaults = new TreeMap<String, String>();
		MessageDigest md5 = null;
		try {
			md5 = MessageDigest.getInstance("MD5");
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		}

		insertContent.clearParameters();
		insertContent.setLong(1, parent);
		insertContent.setInt(2, order);
		insertContent.setString(4, elm.getName());
		
		TreeMap<String,String> values = new TreeMap<String, String>(defaults);
		for (Object _attr : elm.getAttributes()) {
			Attribute attr = (Attribute)_attr;
			String name = attr.getName();
			values.put(name,attr.getValue());
		}
		
		String elmName = null;
		for (Map.Entry<String, String> entry : values.entrySet()) {
			String name = entry.getKey();
			String value = entry.getValue();
			md5.update(name.getBytes());
			md5.update(value.getBytes());
			FieldDescriptor fd = contentFields.get(name);
			if (name.equals("name")) elmName = value;
			if (fd != null) {
				int index = fd.columnIndex;
				switch (fd.columnType) {
				case TYPE_FLOAT:
					insertContent.setFloat(index, Float.parseFloat(value));
					break;
				case TYPE_FILE:
					filesToCopy.add(value);
					if (index != -1) insertContent.setString(index, value);
					else extras.put(name, value);
					break;
				case TYPE_STRING:
					if (name.endsWith("_file")) {
						filesToCopy.add(value);
					}
					if (index != -1) insertContent.setString(index, value);
					else extras.put(name, value);
					break;
				case TYPE_THEME_REFERENCE:
					break;
				case TYPE_CONTENT_REFERENCE:
				case TYPE_MULTI_CONTENT_REFERENCE:
					break;
				}
			} else {
				if (name.endsWith("_file")) {
					filesToCopy.add(value);
				}

				if (name.startsWith("child_")) {
					childDefaults.put(name.substring(6), value);
				} else {
					extras.put(name, value);
				}
			}
		}

		String text = elm.getText().trim();
		if (text.matches("^\\p{Space}*$")) {
			text = null;
		} else {
			text = convertHTML(text);
			md5.update(text.getBytes());
		}
		
		System.out.println(""+elmName+": '"+text+"'");
		
		byte[] digest = md5.digest();
		String uniqueID = getHexString(digest);
		String identity = values.get("identity");
		if (identity != null) {
			uniqueID = "EXPLICIT_"+identity;
			if (uniqueIDs.contains(uniqueID)) {
				String msg = "Already saw explicit ID '"+identity+"', "+insertContent.toString()+" from "+values.toString();
				System.out.println(msg);
				throw new RuntimeException(msg);
			}
		} else {
			if (uniqueIDs.contains(uniqueID)) {
				String msg = "Already saw implicit ID '"+identity+"', mutating";
				System.out.println(msg);
				uniqueID = uniqueID + "_" + elmCount;
			}
		}
		
		uniqueIDs.add(uniqueID);
		insertContent.setString(3, uniqueID);

		elmCount++;
		try {
			insertContent.execute();
		} catch (SQLException e) {
			System.out.println("Error trying to insert "+insertContent.toString()+" from "+values.toString());
			e.printStackTrace();
		}
		ResultSet rs = insertContent.getGeneratedKeys();
		long id = -1;
		if (rs.next()) {
			id = rs.getLong("last_insert_rowid()");
		}
		rs.close();
		
		insertContentText.setLong(1, id);
		insertContentText.setString(2, text);
		if (extras.isEmpty()) {
			insertContentText.setNull(3, java.sql.Types.BLOB);
		} else {
			insertContentText.setBytes(3, serialize(extras));
		}
		insertContentText.execute();

		/*
						queryContentByName.setString(1, value);
						ResultSet rs = queryContentByName.executeQuery();
						if (rs.next()) {
							long id = rs.getLong("_id");
							insertContent.setLong(index, id);
						} else {
							throw new RuntimeException("Could not find content for referenced name '"+value+"'");
						}
						rs.close();
						break;
					}
					*/
		
		for (Map.Entry<String, String> entry : values.entrySet()) {
			String name = entry.getKey();
			String value = entry.getValue();
			FieldDescriptor fd = contentFields.get(name);
			if (fd != null) {
				switch (fd.columnType) {
					case TYPE_CONTENT_REFERENCE:
					case TYPE_MULTI_CONTENT_REFERENCE: {
						String[] refs = value.split("\\p{Space}");
						for (String ref : refs) {
							UnresolvedReference refrec = new UnresolvedReference(id, name, ref);
							refsToResolve.add(refrec);
						}
					}
				}
			}
		}
		
		int childOrder = 0;
		for (Object _child : elm.getChildren()) {
			Element child = (Element)_child;
			addContent(id,childOrder,childDefaults,child);
			childOrder++;
		}

	}
	
	public static boolean deleteRecursive(File path) throws FileNotFoundException{
        if (!path.exists()) return true;
        boolean ret = true;
        if (path.isDirectory()){
            for (File f : path.listFiles()){
                ret = ret && deleteRecursive(f);
            }
        }
        return ret && path.delete();
    }

    public static void mkdirs(File dir) throws IOException {
        File d = dir.getParentFile();
        if (!d.exists()) mkdirs(d);
        dir.mkdir();
    }

    public static void copyFile(File sourceFile, File destFile) throws IOException {
	    if(!destFile.exists()) {
            File d = destFile.getParentFile();
            mkdirs(d);
	        destFile.createNewFile();
	    }

	    FileChannel source = null;
	    FileChannel destination = null;

	    try {
	        source = new FileInputStream(sourceFile).getChannel();
	        destination = new FileOutputStream(destFile).getChannel();
	        destination.transferFrom(source, 0, source.size());
	    }
	    finally {
	        if(source != null) {
	            source.close();
	        }
	        if(destination != null) {
	            destination.close();
	        }
	    }
	}
	
	static public void main(String[] args) throws JDOMException, IOException, SQLException, InterruptedException {		

        System.out.println(args[0]);
        System.out.println(args[1]);
        System.out.println(args[2]);
        System.out.println(args[3]);

		File srcFile = new File(args[0]);
		File dstFile = new File(args[1]);
		
		if (srcFile.lastModified() < dstFile.lastModified()) return;

		init(args[1]);

		SAXBuilder builder = new SAXBuilder();
		Document doc = builder.build(srcFile);
		Element root = doc.getRootElement();
		int order = 0;
		for (Object _elm : root.getChildren()) {
			Element elm = (Element)_elm;
			addElement(-1, order, new TreeMap<String, String>(), elm);
			order++;
		}
		
		for (UnresolvedReference ref : refsToResolve) {
			FieldDescriptor fd = contentFields.get(ref.field);
			switch (fd.columnType) {
			case TYPE_CONTENT_REFERENCE:
			case TYPE_MULTI_CONTENT_REFERENCE:
				insertContentLink.setLong(1, ref.referrer);
				insertContentLink.setString(2, ref.field);

				queryContentByName.setString(1, ref.referreeName);
				ResultSet rs = queryContentByName.executeQuery();
				if (rs.next()) {
					long id = rs.getLong("_id");
					insertContentLink.setLong(3, id);
				} else {
					throw new RuntimeException("Could not find content for referenced name '"+ref.referreeName+"'");
				}
				rs.close();
				
				insertContentLink.execute();
				break;
			}
		}
		
		String srcDirStr = args[2];
		String dstDirStr = args[3];
		File srcDir = new File(srcDirStr);
		File dstDir = new File(dstDirStr);
		File pngDstDir = new File("/tmp/pngcrunch");
		
		deleteRecursive(pngDstDir);
		pngDstDir.mkdirs();
		dstDir.mkdirs();

		boolean regenPNGs = false;
		for (String fn : filesToCopy) {
			srcFile = new File(srcDir,fn);
			dstFile = new File(dstDir,fn);
			if (srcFile.lastModified() < dstFile.lastModified()) continue;
			if (fn.endsWith(".png")) {
				regenPNGs = true;
				break;
			}
		}
		
		for (String fn : filesToCopy) {
			srcFile = new File(srcDir,fn);
			dstFile = new File(dstDir,fn);

			if (fn.endsWith(".png")) {
				if (!regenPNGs) continue;
				dstFile = new File(pngDstDir,fn);
				copyFile(srcFile,dstFile);
				String[] comp = fn.split("\\.");
				fn = comp[0]+"@2x.png";
				srcFile = new File(srcDir,fn);
				if (srcFile.exists()) {
					dstFile = new File(pngDstDir,fn);
					copyFile(srcFile,dstFile);
				}
			} else {
				if (srcFile.lastModified() < dstFile.lastModified()) continue;
				copyFile(srcFile,dstFile);
			}
		}
		
		if (regenPNGs) {
			ProcessBuilder pb = new ProcessBuilder("/Users/geh/proj/tools/android-sdk-mac_x86/build-tools/19.0.0/aapt","c","-v","-S",pngDstDir.getAbsolutePath(), "-C", dstDir.getAbsolutePath());
			pb.start().waitFor();
		}
	}
}
