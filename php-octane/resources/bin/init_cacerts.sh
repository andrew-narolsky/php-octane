#!/usr/bin/env bash
openssl s_client -showcerts corp.ukrtelecom.loc:636 </dev/null 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p'>/tmp/corp.ukrtelecom.loc.crt
sudo cp /tmp/corp.ukrtelecom.loc.crt /usr/local/share/ca-certificates && sudo update-ca-certificates
