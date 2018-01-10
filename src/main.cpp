#include <iostream>
#include <vector>
#include <string>
#include <cstdlib>
#include <fstream>
#include <algorithm>
#include <iterator>

static std::vector<std::string> configList;

static bool daemon = false;

void initConfigList(int argc, char* argv[])
{
    if (argc == 1 || argc > 3)
    {
        std::cout << "Usage:" << std::endl;
        std::cout << argv[0] << " [daemon/standalone]" << std::endl;
        std::cout << argv[0] << " [daemon/standalone] " << "[path/to/configList]" << std::endl;
        std::exit(0);
    }
    std::string arg(argv[1]);
    if (argc > 1 && arg != "daemon" && arg != "standalone")
    {
        std::cerr << "Unrecognized " << arg << std::endl;
        std::exit(1);
    }
    configList.clear();
    configList.push_back("Stop OpenVPN");
    if (arg == "daemon")
    {
        daemon = true;
        configList.push_back("View log");
    }
    if (argc == 3)
    {
        std::ifstream fin(argv[2]);
        if (!fin)
        {
            std::cerr << "Cannot open " << argv[2] << std::endl;
            std::exit(1);
        }
        std::string line;
        while (std::getline(fin, line))
            if (!line.empty())
                configList.push_back(line);
    }
    else
    {
        std::ifstream fin("/etc/openvpnClientConfigList");
        if (!fin)
        {
            std::vector<std::string> vTmp =
            {
                "client-udp-tls-crypt",
                "client-udp-udpobfuscator",
                "client-udp-obfuscated",
                "client-udp",
                "client-tcp-tls-crypt",
                "client-tcp-obfsproxy",
                "client-tcp"
            };
            std::copy(vTmp.begin(), vTmp.end(), std::back_inserter(configList));
            return;
        }
        std::string line;
        while (std::getline(fin, line))
            if (!line.empty())
                configList.push_back(line);
    }
}

int getUserChoice()
{
    int ret = -1;
    bool first = true;
    do
    {
        if (first)
            first = false;
        else
            std::cout << "\n*************************************\n" << std::endl;
        std::cout << "Please choose one of the following options below:\n" << std::endl;
        for (auto i = 0; i < configList.size(); ++i)
            std::cout << (i + 1) << ". " << configList[i] << std::endl;
        std::cout << "\nEnter your choice between 1 and " << configList.size() << ": ";
        std::cin >> ret;
    } while (ret < 1 || ret > configList.size());
    return ret - 1;
}

int main(int argc, char* argv[])
{
    initConfigList(argc, argv);

    std::string modeStr = (daemon ? "daemon" : "standalone");
    std::cout << "Running OpenVPN in " << modeStr << " mode\n" << std::endl;
    int index = getUserChoice();
    if (index == 0)
    {
        if (daemon)
            return std::system("openvpn.sh daemon stop");
        else
            return std::system("sudo pkill openvpn");
    }
    if (index == 1 && daemon)
        return std::system("openvpn.sh daemon log");
    std::string str;
    if (std::string(argv[1]) == "daemon")
        str = "openvpn.sh daemon start ";
    else
        str = "openvpn.sh standalone ";
    str += configList[index];
    return std::system(str.c_str());
}
