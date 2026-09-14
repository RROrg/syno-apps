// Namespace definition
Ext.ns("RROrg.Kodi");

// Application definition
Ext.define("RROrg.Kodi.AppInstance", {
  extend: "SYNO.SDS.AppInstance",
  appWindowName: "RROrg.Kodi.AppWindow",
  defaultWinSize: { width: 1280, height: 720 },
  constructor: function () {
    this.callParent(arguments);
  },
});

Ext.define("RROrg.Kodi.AppWindow", {
  extend: "SYNO.SDS.AppWindow",
  layout: "fit",
  width: "100%",
  height: "100%",
  initComponent: function () {
    this.items = [
      {
        xtype: "panel",
        border: false,
        html: '<iframe src="/kodi/" style="width:100%;height:100%;border:none;"></iframe>',
      },
    ];
    this.callParent(arguments);
  },
  defaultWinSize: { width: 1280, height: 720 },
  constructor: function (config) {
    const t = this;
    t.callParent([t.fillConfig(config)]);
  },
  fillConfig: function (e) {
    const i = {
      // cls: 'syno-app-kodi',
    };
    return (Ext.apply(i, e), i);
  },
  onDestroy: function (e) {
    RROrg.Kodi.AppWindow.superclass.onDestroy.call(this);
  },
  onOpen: function (a) {
    RROrg.Kodi.AppWindow.superclass.onOpen.call(this, a);
  },
});
