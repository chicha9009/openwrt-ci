#!/usr/bin/env bash
set -Eeuo pipefail

# 修改默认IP & 固件名称 & 编译署名和时间
# sed -i 's/192.168.1.1/192.168.1.254/g' package/base-files/files/bin/config_generate
sed -i "s/hostname='.*'/hostname='Openwrt'/g" package/base-files/files/bin/config_generate
luci_system_js="feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js"
firmware_version_anchor="_('Firmware Version'), (L.isObject(boardinfo.release) ? boardinfo.release.description + ' / ' : '') + (luciversion || ''),"
grep -Fq "$firmware_version_anchor" "$luci_system_js" || { echo "Error: LuCI firmware version anchor was not found in $luci_system_js" >&2; exit 1; }
sed -i "s#_('Firmware Version'), (L\.isObject(boardinfo\.release) ? boardinfo\.release\.description + ' / ' : '') + (luciversion || ''),# \
            _('Firmware Version'),\n \
            E('span', {}, [\n \
                (L.isObject(boardinfo.release)\n \
                ? boardinfo.release.description + ' / '\n \
                : '') + (luciversion || '') + ' / ',\n \
            E('a', {\n \
                href: 'https://github.com/chicha9009/openwrt-ci/releases',\n \
                target: '_blank',\n \
                rel: 'noopener noreferrer'\n \
                }, [ 'Built by 不如吃茶去' ])\n \
            ]),#" "$luci_system_js"

sudo apt install libfuse-dev


# 删除要替换的包
rm -rf feeds/luci/applications/luci-app-adguardhome
#rm -rf feeds/packages/net/adguardhome
rm -rf feeds/packages/lang/golang


git clone --depth=1 https://github.com/chicha9009/luci-app-adguardhome.git package/luci-app-adguardhome
#git clone --depth=1 https://github.com/chicha9009/adguardhome.git package/adguardhome
git clone https://github.com/sbwml/packages_lang_golang -b 25.x feeds/packages/lang/golang

echo "========== 检查 package/mtk/applications 目录内容 =========="
ls -la "$OPENWRT_PATH/package/mtk/applications/"
echo "=========================================================="


./scripts/feeds update -a
./scripts/feeds install -a
