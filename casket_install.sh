#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#=================================================
#       System Required: CentOS/Debian/Ubuntu
#       Description: casket Install
#       Version: 1.0.8
#       Author: Toyo
#       Blog: https://doub.io/shell-jc1/
#=================================================
file="/usr/local/casket/"
casket_file="/usr/local/casket/casket"
casket_conf_file="/usr/local/casket/casketfile"
Info_font_prefix="\033[32m" && Error_font_prefix="\033[31m" && Info_background_prefix="\033[42;37m" && Error_background_prefix="\033[41;37m" && Font_suffix="\033[0m"

check_root(){
	[[ $EUID != 0 ]] && echo -e "${Error} 当前非ROOT账号(或没有ROOT权限)，无法继续操作，请更换ROOT账号或使用 ${Green_background_prefix}sudo su${Font_color_suffix} 命令获取临时ROOT权限（执行后可能会提示输入当前账号的密码）。" && exit 1
}
check_sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
	bit=$(uname -m)
}
check_installed_status(){
	[[ ! -e ${casket_file} ]] && echo -e "${Error_font_prefix}[错误]${Font_suffix} casket 没有安装，请检查 !" && exit 1
}
Download_casket(){
	PID=$(ps -ef |grep "casket" |grep -v "grep" |grep -v "init.d" |grep -v "service" |grep -v "casket_install" |awk '{print $2}')
	[[ ! -z ${PID} ]] && kill -9 ${PID}
        [[ -e "casket_linux*.tar.gz" ]] && rm -rf "casket_linux*.tar.gz"

        #wget -N --no-check-certificate -O "casket_linux.tar.gz" "https://github.com/tmpim/casket/releases/download/v1.1.5/casket_1.1.5_linux_amd64.tar.gz"
        wget -N --no-check-certificate "https://raw.githubusercontent.com/Joyace/shell/master/casket-1.1.5-with-webdav.zip"

	[[ ! -e "casket-1.1.5-with-webdav.zip" ]] && echo -e "${Error_font_prefix}[错误]${Font_suffix} casket 下载失败 !" && exit 1
	unzip casket-1.1.5-with-webdav.zip -d /usr/local/casket
	rm -rf "casket-1.1.5-with-webdav.zip"
	[[ ! -e ${casket_file}/casket-1.1.5-with-webdav ]] && echo -e "${Error_font_prefix}[错误]${Font_suffix} casket 解压失败或压缩文件错误 !" && exit 1
	chmod +x ${casket_file}/casket
}
Service_casket(){
	if [[ ${release} = "centos" ]]; then
		if ! wget --no-check-certificate https://raw.githubusercontent.com/Joyace/shell/master/service/casket_centos -O /etc/init.d/casket; then
			echo -e "${Error_font_prefix}[错误]${Font_suffix} casket服务 管理脚本下载失败 !" && exit 1
		fi
		chmod +x /etc/init.d/casket
		chkconfig --add casket
		chkconfig casket on
	else
		if ! wget --no-check-certificate https://raw.githubusercontent.com/Joyace/shell/master/service/casket_debian -O /etc/init.d/casket; then
			echo -e "${Error_font_prefix}[错误]${Font_suffix} casket服务 管理脚本下载失败 !" && exit 1
		fi
		chmod +x /etc/init.d/casket
		update-rc.d -f casket defaults
	fi
}
install_casket(){
	check_root
	if [[ -e ${casket_file} ]]; then
		echo && echo -e "${Error_font_prefix}[信息]${Font_suffix} 检测到 casket 已安装，是否继续安装(覆盖更新)？[y/N]"
		read -e -p "(默认: n):" yn
		[[ -z ${yn} ]] && yn="n"
		if [[ ${yn} == [Nn] ]]; then
			echo && echo "已取消..." && exit 1
		fi
	fi
	Download_casket
	Service_casket
	echo && echo -e " casket 使用命令：${casket_conf_file}
 日志文件：cat /tmp/casket.log
 使用说明：service casket start | stop | restart | status
 或者使用：/etc/init.d/casket start | stop | restart | status
 ${Info_font_prefix}[信息]${Font_suffix} casket 安装完成！" && echo
}
uninstall_casket(){
	check_installed_status
	echo && echo "确定要卸载 casket ? [y/N]"
	read -e -p "(默认: n):" unyn
	[[ -z ${unyn} ]] && unyn="n"
	if [[ ${unyn} == [Yy] ]]; then
		PID=`ps -ef |grep "casket" |grep -v "grep" |grep -v "init.d" |grep -v "service" |grep -v "casket_install" |awk '{print $2}'`
		[[ ! -z ${PID} ]] && kill -9 ${PID}
		if [[ ${release} = "centos" ]]; then
			chkconfig --del casket
		else
			update-rc.d -f casket remove
		fi
		[[ -s /tmp/casket.log ]] && rm -rf /tmp/casket.log
		rm -rf ${casket_file}
		rm -rf ${casket_conf_file}
		rm -rf /etc/init.d/casket
		[[ ! -e ${casket_file} ]] && echo && echo -e "${Info_font_prefix}[信息]${Font_suffix} casket 卸载完成 !" && echo && exit 1
		echo && echo -e "${Error_font_prefix}[错误]${Font_suffix} casket 卸载失败 !" && echo
	else
		echo && echo "卸载已取消..." && echo
	fi
}
check_sys
action=$1
extension=$2
[[ -z $1 ]] && action=install
case "$action" in
    install|uninstall)
    ${action}_casket
    ;;
    *)
    echo "输入错误 !"
    echo "用法: {install | uninstall}"
    ;;
esac
