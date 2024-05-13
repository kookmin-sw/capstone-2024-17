async function deleteCompanyRequest(id) {
    await fetch(`/company/request?companyRequestId=${id}`, {
        method: 'DELETE',
    }).catch(err => {
        console.log(err)
    }).then(response => response.json())
        .then(data => {
            alert(`${data.success ? data.data : data.message}`);
            location.replace(location.href); // 새로고침
        });
}

