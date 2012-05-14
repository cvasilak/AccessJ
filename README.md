![AccessJ][1]

AccessJ is an iPhone front-end to [Java Management Extensions (JMX)][0]. It will allow you to easily configure a remote Java Application as long as it exposes its information as management beans. For it's remote back-end Java/JMX engine it uses the excellent [Jolokia][2] library.

A demo server (JBoss 6) is provided so that you can experience the application running. (Note that that server is in read-only mode for obvious reasons.)

Features
--------

The application supports the following features:

* __Secure Communication__

   If username/password credentials are supplied by the user, the application establishes an HTTPS/SSL connection to the server together with Basic Authentication. The feature implies that the user has correctly setup the remote back-end to support it. Take note that [Jolokia][2] offers comprehensive security mechanisms, that can be configured by the user for more fine grained security of the MBeans exposed by the agent. Please consult the [Jolokia][2] documentation for more information.

* __Browsing of the full JMX Management tree__

  The tree is sorted based on the "keyPropertyList" configurable by the user a.l.a [JConsole][3]. Default is by "type" and the order of the "key=value" properties as defined in the ObjectName of the MBean. More information about the ordering can be found in the [JConsole][3] documentation.

* __Allows editing of read/write attributes of an MBean__

  Upon clicking a read/write attribute name, the user is prompted to edit the value. Common editors are supported (string, integer, boolean)

* __Allows execution of supported MBean operations__

  Operations that accept standard types (e.g. integer,string,boolean) are supported. Future work is already in progress to support more complex types(a.k.a Composites) now that the Jolokia library in its newest version(v0.95 upwards), supports it.

* __Allows graphing of an MBean attribute__

  For attributes of type number, a nice graph is displayed upon clicking the attribute. The update interval is configurable by the user (default is 2 seconds with max value 15 seconds)

Future work
-----------

Now that we have core functionality in-place, the following are some areas of future work:

* __Searching__

* __Bookmarking__

* __Plotting of more than one attribute simultaneously__

* __Java VM MXBeans "one-click-access"__

* __JMX to IOS Notification bridge__




[0]: http://en.wikipedia.org/wiki/Java_Management_Extensions
[1]: http://cvasilak.org/images/accessj-logo.png "AccessJ"
[2]: http://www.jolokia.org/
[3]: http://download.oracle.com/javase/6/docs/technotes/guides/management/jconsole.html
