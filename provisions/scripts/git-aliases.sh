cd
touch .gitconfig

GIT_CONFIG=$(cat <<EOF
[alias]
	co = checkout
	br = branch
	st = status
[color]
	ui = always
EOF
)

echo "${GIT_CONFIG}" >> .gitconfig
