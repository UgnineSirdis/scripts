PATH="$SCRIPTS_DIR:$HOME/.local/bin:$PATH"
PATH="$PATH:$(go env GOPATH)/bin"

alias jump-test="tsh kube login --proxy=bastion.man.nebiusinfra.net:443 man-common-testing && kubectl exec -it ydb-jump-host-0 -n ydb-global -- env YDB_TOKEN=\$(npc --profile testing iam get-access-token) bash"
alias jump-dev="tsh kube login --proxy=bastion.man.nebiusinfra.net:443 man-ydb-dev && kubectl exec -it ydb-jump-host-0 -n ydb-dev -- env YDB_TOKEN=\$(npc --profile testing iam get-access-token) bash"
alias jump-slice="tsh kube login --proxy=bastion.man.nebiusinfra.net:443 man-ydb-dev && kubectl exec -it ydb-jump-host-0 -n ydb-dev -- env YDB_TOKEN=\$(npc --profile testing iam get-access-token) bash"
alias jump-prod-kcs="tsh kube login --proxy=bastion.kcs.nebiusinfra.net:443 kcs-common-prod && kubectl exec -it ydb-jump-host-0 -n ydb-common -- env YDB_TOKEN=\$(npc --profile prod iam get-access-token) bash"
alias jump-prod-kef="tsh kube login --proxy=bastion.kef.nebiusinfra.net:443 kef-common-prod && kubectl exec -it ydb-jump-host-0 -n ydb-common -- env YDB_TOKEN=\$(npc --profile prod iam get-access-token) bash"
alias jump-prod-man="tsh kube login --proxy=bastion.man.nebiusinfra.net:443 man-common-prod && kubectl exec -it ydb-jump-host-0 -n ydb-common -- env YDB_TOKEN=\$(npc --profile prod iam get-access-token) bash"
alias jump-prod-pa10="tsh kube login --proxy=bastion.pa10.nebiusinfra.net:443 pa10-common-prod && kubectl exec -it ydb-jump-host-0 -n ydb-common -- env YDB_TOKEN=\$(npc --profile prod iam get-access-token) bash"
alias jump-prod-bic="tsh kube login --proxy=bastion.bic.nebiusinfra.net:443 bic-common-prod && kubectl exec -it ydb-jump-host-0 -n ydb-common -- env YDB_TOKEN=\$(npc --profile prod iam get-access-token) bash"
alias jump-prod-irg="tsh kube login --proxy=bastion.irg.nebiusinfra.net:443 irg-common-prod && kubectl exec -it ydb-jump-host-0 -n ydb-common -- env YDB_TOKEN=\$(npc --profile prod iam get-access-token) bash"
alias jump-prod-lcp="tsh kube login --proxy=bastion.lcp.nebiusinfra.net:443 lcp-common-prod && kubectl exec -it ydb-jump-host-0 -n ydb-common -- env YDB_TOKEN=\$(npc --profile prod iam get-access-token) bash"
alias jump-prod-lne="tsh kube login --proxy=bastion.lne.nebiusinfra.net:443 lne-common-prod && kubectl exec -it ydb-jump-host-0 -n ydb-common -- env YDB_TOKEN=\$(npc --profile prod iam get-access-token) bash"
alias jump-prod-mad="tsh kube login --proxy=bastion.mad.nebiusinfra.net:443 mad-common-prod && kubectl exec -it ydb-jump-host-0 -n ydb-common -- env YDB_TOKEN=\$(npc --profile prod iam get-access-token) bash"
alias jump-prod-mdc="tsh kube login --proxy=bastion.mdc.nebiusinfra.net:443 mdc-common-prod && kubectl exec -it ydb-jump-host-0 -n ydb-common -- env YDB_TOKEN=\$(npc --profile prod iam get-access-token) bash"

# How to find the cluster's context:
#   tsh kube login
# then:
#   kubectl config current-context
alias k9s-test='kubectl config use-context bastion-man-man-common-testing ; k9s -n ydb-global'
alias k9s-dev='kubectl config use-context bastion-man-man-ydb-dev ; k9s -n ydb-dev'
alias k9s-slice='kubectl config use-context bastion-man-man-ydb-dev ; k9s -n ydb-slice-1'
alias k9s-prod-kcs='kubectl config use-context bastion-kcs-kcs-common-prod ; k9s -n ydb-common'
alias k9s-prod-kef='kubectl config use-context bastion-kef-kef-common-prod ; k9s -n ydb-common'
alias k9s-prod-man='kubectl config use-context bastion-man-man-common-prod ; k9s -n ydb-common'
alias k9s-prod-pa10='kubectl config use-context bastion-pa10-pa10-common-prod ; k9s -n ydb-common'
