// Namespace definition
Ext.ns("RROrg.ChromiumDesktop");

// Application definition
Ext.define("RROrg.ChromiumDesktop.AppInstance", {
  extend: "SYNO.SDS.AppInstance",
  appWindowName: "RROrg.ChromiumDesktop.AppWindow",
  defaultWinSize: { width: 1160, height: 700 },
  constructor: function () {
    this.callParent(arguments);
  },
});

Ext.define("RROrg.ChromiumDesktop.AppWindow", {
  extend: "SYNO.SDS.AppWindow",
  layout: "fit",
  width: "100%",
  height: "100%",
  initComponent: function () {
    const path = window.location.pathname.replace(/[/]+$/, "");
    this.items = [
      {
        xtype: "panel",
        border: false,
        html: '<iframe src="/chromium-desktop/vnc.html?autoconnect=true&autoscale=scale&resize=scale" style="width:100%;height:100%;border:none;"></iframe>',
      },
    ];
    this.callParent(arguments);
  },
  defaultWinSize: { width: 1160, height: 700 },
  constructor: function (config) {
    const t = this;
    t.callParent([t.fillConfig(config)]);
  },
  fillConfig: function (e) {
    const i = {
      // cls: 'syno-app-iscsi',
    };
    return (Ext.apply(i, e), i);
  },
  onDestroy: function (e) {
    RROrg.ChromiumDesktop.AppWindow.superclass.onDestroy.call(this, e);
  },
  onOpen: function (a) {
    RROrg.ChromiumDesktop.AppWindow.superclass.onOpen.call(this, a);
  },
});
